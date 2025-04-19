class_name GameManager
extends Node2D


signal mark_count_changed(mark_count: int)
signal undo_count_changed(undo_count: int)
signal game_state_changed(game_state: GameState)
signal turn_changed(turn_count: int)
signal battle_time_changed(battle_time: int)
signal level_changed(level_title: String)
signal level_completed()
signal level_lost(undo_count: int)
signal paused()
signal unpaused()


enum GameState {
	INIT = 0,
	START = 1,
	BATTLE = 2,
	GAME_OVER = 3,
	GAME_WIN = 4,
	PAUSE = 5,
}

@export var levels: Array[LevelInfo]


var current_level: int = 0
var enemies_count: int = 0
var mark_count: int = 10 
var undo_count: int = 3
var battle_time: int = 0
var game_state: GameState
var _prev_game_state: GameState
var _game_state_changing: bool = false


@onready var map: Map = $"../Map"
@onready var map_generator: MapGenerator = $"../MapGenerator"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var turn_queue: TurnQueue = $TurnQueue
@onready var character: Character = $"../Character"


func _ready():
	game_state = GameState.INIT
	turn_queue.turn_changed.connect(_on_turn_end)
	map.cell_marked.connect(_on_cell_marked)
	map.cell_opened.connect(_on_cell_opened)
	character.died.connect(_on_character_died)
	restart_game()


func _unhandled_input(event: InputEvent) -> void:
	if game_state == GameState.GAME_OVER \
		|| game_state == GameState.GAME_WIN \
		|| game_state == GameState.PAUSE \
		|| game_state == GameState.INIT \
		|| turn_queue.is_turn_processing:
		return
	
	if event.is_action_pressed("LeftMouseButton"):
		if game_state == GameState.START:
			print("GameManager: first turn")
			var cell_pos = map.get_cell_pos(event.global_position)
			map_generator.fill_map(map, cell_pos)
			change_game_state(GameState.BATTLE)
			battle_timer.start()
		
		if map.open_cell_at_global_position(event.global_position):
			var command = EndTurnCommand.new()
			turn_queue.add_command(command)
	elif event.is_action_pressed("RightMouseButton"):
		if game_state == GameState.BATTLE:
			map.mark_cell_global_position(event.global_position)


func start_next_level() -> void:
	current_level += 1
	var callback = Callable(self, "prepare_level")
	Transition.play_transition_in(callback)
	await Transition.fade_out_completed
	change_game_state(GameState.START)


func prepare_level() -> void:
	var level_template : LevelInfo = null
	for i in levels.size():
		var levels_range = levels[i].level_range
		if current_level >= levels_range[0] && current_level <= levels_range[1]:
			level_template = levels[i]
			break
	if level_template == null:
		level_template = levels[-1]
	
	level_template.generate_level(current_level)
	level_changed.emit(level_template._title)
	enemies_count = level_template.get_enemy_count()
	map_generator.set_enemies_info(level_template._enemies)
	map_generator.set_map_data(level_template._map_x, level_template._map_y)
	map_generator.generate_empty_map(map)
	
	turn_queue.reset()
	mark_count = enemies_count
	mark_count_changed.emit(mark_count)


func restart_game() -> void:
	print("Restart game")
	var callback = Callable(self, "prepare_game")
	Transition.play_transition_in(callback)
	await Transition.fade_out_completed
	change_game_state(GameState.START)


func prepare_game() -> void:
	battle_timer.stop()
	battle_time = 0
	battle_time_changed.emit(battle_time)
	undo_count = 3
	undo_count_changed.emit(undo_count)
	character.reset()
	current_level = 0
	prepare_level()


func change_game_state(new_state: GameState) -> void:
	if game_state == new_state:
		print("Already in state " + str(new_state))
		return
	
	if _game_state_changing:
		print("Try to break game state change")
		return
	
	_game_state_changing = true
	exit_state(game_state)
	enter_state(new_state)
	_prev_game_state = game_state
	game_state = new_state
	game_state_changed.emit(game_state)
	print("State changed. " + str(_prev_game_state) + "->" + str(new_state))
	_game_state_changing = false


func exit_state(state: GameState) -> void:
	if game_state == GameState.PAUSE:
		map.start_show()
		await get_tree().create_timer(0.2).timeout
		battle_timer.paused = false
		unpaused.emit()
	elif state == GameState.GAME_OVER || state == GameState.GAME_WIN:
		battle_timer.paused = false


func enter_state(state: GameState) -> void:
	if state == GameState.PAUSE:
		battle_timer.paused = true
		map.start_hide()
		paused.emit()
	elif state == GameState.GAME_OVER || state == GameState.GAME_WIN:
		battle_timer.paused = true


func revert_game_over() -> void:
	#TODO maybe not needed in future
	print("Revert game lost")
	change_game_state(GameState.BATTLE)


func check_board_cleared() -> void:
	var closed_cells: Array[Vector2i] = map.get_closed_cells()
	if closed_cells.size() > enemies_count:
		return
	
	var enemies_cells = map.get_enemis_cells()
	for i in closed_cells:
		if i not in enemies_cells:
			return
	
	print("GameManager: Level " + str(current_level) + " completed")
	change_game_state(GameState.GAME_WIN)
	level_completed.emit()


func _on_battle_timer_timeout() -> void:
	battle_time += 1
	battle_time_changed.emit(battle_time)


func _on_cell_marked(value: bool) -> void:
	if value:
		mark_count -= 1
	else:
		mark_count += 1
	mark_count_changed.emit(mark_count)


func _on_cell_opened(cell_type: Map.CellType, opened_obj: Node = null) -> void:
	if cell_type == Map.CellType.ENEMY:
		var command = EnemyEnteredCommand.new(character, opened_obj as Enemy)
		turn_queue.add_command(command)
	else:
		check_board_cleared()


func _on_turn_end(turn: int) -> void:
	turn_changed.emit(turn)


func _on_character_died():
	change_game_state(GameState.GAME_OVER)
	var command = GameOverCommand.new()
	command.undo_callback = Callable(self, "revert_game_over")
	turn_queue.add_command(command)
	level_lost.emit()


func pause() -> void:
	if game_state == GameState.PAUSE:
		change_game_state(_prev_game_state)
	else:
		change_game_state(GameState.PAUSE)


func undo() -> void:
	if (game_state == GameState.BATTLE \
		|| game_state == GameState.GAME_OVER) \
		&& undo_count > 0 && turn_queue.is_undo_possible():
		undo_count -= 1
		undo_count_changed.emit(undo_count)
		turn_queue.undo(1)
