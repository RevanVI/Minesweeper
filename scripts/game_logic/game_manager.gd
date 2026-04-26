class_name GameManager
extends Node2D


signal mark_count_changed(mark_count: int)
signal undo_count_changed(undo_count: int)
signal undo_status_changed(available: bool)
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


var enemies_count: int = 0
var mark_count: int = 10
var battle_time: int = 0
var game_state: GameState
var _prev_game_state: GameState
var _game_state_changing: bool = false
var _modifier_list: ModifiersList


@onready var map: Map = $"../Map"
@onready var map_generator: MapGenerator = $"../MapGenerator"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var turn_queue: TurnQueue = $TurnQueue
@onready var camera_controller: CameraController = $"../CameraController"
var _character: Character


func _ready():
	game_state = GameState.INIT
	turn_queue.turn_changed.connect(_on_turn_end)
	map.cell_marked.connect(_on_cell_marked)
	map.cell_opened.connect(_on_cell_opened)


func _unhandled_input(event: InputEvent) -> void:
	if game_state == GameState.GAME_OVER \
		|| game_state == GameState.GAME_WIN \
		|| game_state == GameState.PAUSE \
		|| game_state == GameState.INIT \
		|| turn_queue.is_turn_processing:
		return
	
	if event.is_action_pressed("LeftMouseButton"):
		var global_pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
		if game_state == GameState.START:
			print("GameManager: first turn")
			var cell_pos = map.get_cell_pos(global_pos)
			map_generator.populate_map(map, cell_pos)
			change_game_state(GameState.BATTLE)
			battle_timer.start()
		
		if map.open_cell_at_global_position(global_pos):
			var command = EndTurnCommand.new()
			turn_queue.add_command(command)
	elif event.is_action_pressed("RightMouseButton"):
		if game_state == GameState.BATTLE:
			var global_pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
			map.mark_cell_global_position(global_pos)


func prepare_level(level_info: LevelInfo) -> void:
	level_changed.emit(level_info.title)
	turn_queue.reset()
	map.set_modifiers(_modifier_list)
	map_generator.generate_empty_map(map, level_info.map_size, level_info.get_enemies_data(), _modifier_list)
	camera_controller.pos_limits = map.get_limits()
	camera_controller.calc_start_position()
	enemies_count = level_info.get_enemy_count()
	mark_count = enemies_count
	mark_count_changed.emit(mark_count)


func prepare_battle(level_info: LevelInfo, character: Character) -> void:
	_character = character
	if _character.is_connected("died", _on_character_died) == false:
		_character.died.connect(_on_character_died)
	battle_timer.stop()
	battle_time = 0
	battle_time_changed.emit(battle_time)

	# TODO collect modifiers from all sources
	_modifier_list = ModifiersList.new()
	_modifier_list.add_modifiers(level_info.modifiers)

	if _modifier_list.get_modifier_by_tag(ModifierBase.ModifierTag.UNDO_BLOCKED):
		undo_status_changed.emit(false)

	undo_count_changed.emit(_character.get_undo_count())
	prepare_level(level_info)
	change_game_state(GameState.START)


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
	
	print("GameManager: Level completed")
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
		var command = EnemyEnteredCommand.new(_character, opened_obj as Enemy)
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
	var undo_count = _character.get_undo_count()
	if (game_state == GameState.BATTLE \
		|| game_state == GameState.GAME_OVER) \
		&& undo_count > 0 && turn_queue.is_undo_possible():
		undo_count -= 1
		undo_count_changed.emit(undo_count)
		_character.set_undo_count(undo_count)
		turn_queue.undo(1)


func get_undo_status() -> bool:
	if _character.get_undo_count() <= 0 or \
		_modifier_list.get_modifier_by_tag(ModifierBase.ModifierTag.UNDO_BLOCKED):
		return false
	return true
