class_name GameManager
extends Node2D


signal mark_count_changed(mark_count: int)
signal undo_count_changed(undo_count: int)
signal game_state_changed(game_state: GameState)
signal turn_changed(turn_count: int)
signal battle_time_changed(battle_time: int)


enum GameState {
	START = 0,
	BATTLE = 1,
	GAME_OVER = 2,
	PAUSE = 3,
}


@export var map_size: Vector2i = Vector2i(10, 10)
@export var levels: Array[LevelInfo]


var current_level: int = 0
var enemies_count: int = 0
var mark_count: int = 10 
var undo_count: int = 3
var battle_time: int = 0
var game_state: GameState
var hp: int = 5


@onready var map: Map = $"../Map"
@onready var map_generator: MapGenerator = $"../MapGenerator"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var turn_queue: TurnQueue = $TurnQueue


func _ready():
	turn_queue.turn_changed.connect(_on_turn_end)
	map.size = map_size
	map.cell_marked.connect(_on_cell_marked)
	map.cell_opened.connect(_on_cell_opened)
	restart()


func _unhandled_input(event: InputEvent) -> void:
	if game_state == GameState.GAME_OVER || turn_queue.is_turn_processing:
		return
	
	if event.is_action_pressed("LeftMouseButton"):
		if map.get_cells_total() == map.get_closed_cells_count():
			map_generator.map_size = map_size
			var cell_pos = map.get_cell_pos(event.global_position)
			map_generator.generate_map(map, cell_pos)
			change_game_state(GameState.BATTLE)
			battle_timer.start()
		
		if map.open_cell_at_global_position(event.global_position):
			var command = EndTurnCommand.new()
			turn_queue.add_command(command)
	elif event.is_action_pressed("RightMouseButton"):
		map.mark_cell_global_position(event.global_position)


func start_level(level: int) -> void:
	current_level = level
	map.reset_board()
	map.reset_cells()
	turn_queue.reset()
	level = min(level, levels.size() - 1)
	enemies_count = levels[level].get_enemy_count()
	mark_count = enemies_count
	mark_count_changed.emit(mark_count)
	map_generator.set_enemies_info(levels[level].enemies)
	change_game_state(GameState.START)


func restart() -> void:
	map.reset_board()
	map.reset_cells()
	mark_count = enemies_count
	mark_count_changed.emit(mark_count)
	battle_timer.stop()
	battle_time = 0
	battle_time_changed.emit(battle_time)
	undo_count = 3
	undo_count_changed.emit(undo_count)	
	turn_queue.reset()
	current_level = 0
	start_level(current_level)


func change_game_state(new_state: GameState) -> void:
	game_state = new_state	
	game_state_changed.emit(game_state)
	print("State changed. New state: " + str(new_state))


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
	
	print("Level " + str(current_level) + " completed")
	call_deferred("start_level", current_level + 1)


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
		var command = EnemyEnteredCommand.new(opened_obj as Enemy)
		turn_queue.add_command(command)
		
		if hp <= 0:
			change_game_state(GameState.GAME_OVER)
			command = GameOverCommand.new()
			command.undo_callback = Callable(self, "revert_game_over")
			turn_queue.add_command(command)
	else:
		check_board_cleared()


func _on_turn_end(turn: int) -> void:
	turn_changed.emit(turn)


func undo() -> void:
	if undo_count > 0:
		undo_count -= 1
		undo_count_changed.emit(undo_count)
		turn_queue.undo(1)
