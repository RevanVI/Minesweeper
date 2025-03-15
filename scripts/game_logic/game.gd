extends Node2D

enum GameState {
	START = 0,
	BATTLE = 1,
	GAME_OVER = 2,
	PAUSE = 3,
}


@onready var map: Map = $"../Map"
@onready var map_generator: MapGenerator = $"../MapGenerator"
@onready var battle_timer: Timer = $"../BattleTimer"


@export var map_size: Vector2i = Vector2i(10, 10)
@export var mines_count: int = 10

var mark_count: int = 10
var battle_time: int = 0
var game_state: GameState

signal mark_count_changed(mark_count)
signal game_state_changed(game_state: GameState)

func _ready():
	map.size = map_size
	map.cell_marked.connect(on_cell_marked)
	map.cell_opened.connect(on_cell_opened)
	
	restart()


func _unhandled_input(event: InputEvent) -> void:
	if game_state == GameState.GAME_OVER:
		return
	
	if event.is_action_pressed("LeftMouseButton"):
		if map.get_cells_total() == map.get_closed_cells():
			map_generator.map_size = map_size
			map_generator.mines_count = mines_count
			var cell_pos = map.get_cell_pos(event.global_position)
			map_generator.generate_map(map, cell_pos)
			change_game_state(GameState.BATTLE)
			battle_timer.start()
		map.open_cell_at_global_position(event.global_position)
	elif event.is_action_pressed("RightMouseButton"):
		map.mark_cell_global_position(event.global_position)


func on_cell_marked(value: bool) -> void:
	if value:
		mark_count -= 1
	else:
		mark_count += 1
	mark_count_changed.emit(mark_count)


func on_cell_opened(tile_type) -> void:
	if tile_type == map.mine_tile:
		print("game over")
		$"../RestartTimer".start()
		change_game_state(GameState.GAME_OVER)
	elif map.get_closed_cells() == mines_count:
		print("win")
		$"../RestartTimer".start()
		change_game_state(GameState.GAME_OVER)


func restart() -> void:
	map.reset_board()
	map.reset_cells()
	mark_count = mines_count
	mark_count_changed.emit(mark_count)
	battle_timer.stop()
	change_game_state(GameState.START)


func _on_restart_timer_timeout() -> void:
	restart()


func change_game_state(new_state: GameState) -> void:
	game_state = new_state
	game_state_changed.emit(game_state)
	print("State changed. New state: " + str(new_state))


func _on_battle_timer_timeout() -> void:
	battle_time += 1
