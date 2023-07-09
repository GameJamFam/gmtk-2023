extends Node
# Tilemap IDs
const APPLE=0
const SNAKE=1
@export var snake_instance: PackedScene
const WALL=2
@export var sfx_game_over: AudioStream
@export var sfx_ouroboros: AudioStream
@export var sfx_power_up: AudioStream
@export var sfx_power_up_used: AudioStream
@export var sfx_power_up_expired: AudioStream
@export var sfx_power_up_appears: AudioStream
@export var sfx_power_up_disappears: AudioStream
@export var sfx_level_end: AudioStream
@export var sfx_snake_added: AudioStream
@export var sfx_wall_appears: AudioStream
@export var sfx_board_transition: AudioStream

@onready var sfx_paths = {
	game_over=sfx_game_over,
	ouroboros=sfx_ouroboros,
	power_up=sfx_power_up,
	power_up_used=sfx_power_up_used,
	power_up_expired=sfx_power_up_expired,
	power_up_appears=sfx_power_up_appears,
	power_up_disappears=sfx_power_up_disappears,
	level_end=sfx_level_end,
	snake_added=sfx_snake_added,
	wall_appears=sfx_wall_appears,
	board_transition=sfx_board_transition
}

func play_sfx(key):
	if key != "":
		var s = sfx_paths[key]
		if s != null:
			$SFX.set_stream(s)
			$SFX.play()

# Generated Walls
const T_WALL_BIG = [
	Vector2i(-3,0), Vector2i(-2,0), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0),
													Vector2i(0,1),
													Vector2i(0,2),
													Vector2i(0,3),
	]
const L_WALL_BIG = [
	Vector2i(0,-3),
	Vector2i(0,-2),
	Vector2i(0,-1),
	Vector2i(0,0), Vector2i(1,3), Vector2i(2,3), Vector2i(3,3),
]
const U_WALL_BIG = [
	Vector2i(-2,-3),											Vector2i(2,-3),
	Vector2i(-2,-2),											Vector2i(2,-2),
	Vector2i(-2,-1),											Vector2i(2,-1),
	Vector2i(-2,0), Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),
]
const S_WALL_BIG = [
													Vector2i(0,-2), Vector2i(1,-2), Vector2i(2,-2), Vector2i(3,-2),
													Vector2i(0,-1),
													Vector2i(0,0),
													Vector2i(0,1),
	Vector2i(-3,2), Vector2i(-2,2), Vector2i(-1,2), Vector2i(0,2),
]
const Z_WALL_BIG = [
	Vector2i(-3,-2), Vector2i(-2,-2), Vector2i(-1,-2),  Vector2i(0,-2),
														Vector2i(0,-1),
														Vector2i(0,0),
														Vector2i(0,1),
														Vector2i(0,2), Vector2i(1,2), Vector2i(2,2), Vector2i(3,2),
]
const T_WALL = [
	Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0),
					Vector2i(0,1),
]
const L_WALL = [
	Vector2i(0,-1),
	Vector2i(0,0), Vector2i(1,3),
]
const U_WALL = [
	Vector2i(-1,-1),				Vector2i(1,-1),
	Vector2i(-1,0), Vector2i(0,0), Vector2i(1,0),
]
const S_WALL = [
					Vector2i(0,-1), Vector2i(1,-1),
					Vector2i(0,0),
	Vector2i(-1,1), Vector2i(0,1),
]
const Z_WALL = [
	Vector2i(-1,-1),  Vector2i(0,-1),
						Vector2i(0,0),
						Vector2i(0,1), Vector2i(1,1)
]
const WALL_CHOICES = [T_WALL, L_WALL, U_WALL, S_WALL, Z_WALL]
@onready var powerup = null

func get_tile_at(layer,x,y):
	var v = Vector2(x,y)
	return $TileMap.get_cell_atlas_coords(layer, v)

func rot(deg, vec2i):
	match deg:
		-90:
			return Vector2i(vec2i.y, -vec2i.x)
		-180:
			return Vector2i(-vec2i.x, -vec2i.y)
		-270:
			return Vector2i(-vec2i.y, vec2i.x)
		_:
			return vec2i
	
func random_rotation():
	return (randi() % 3) * -90

func spawn_snake():
	var snake = snake_instance.instantiate()
	snake.snake_num = $Snakes.get_child_count()
	$Snakes.add_child(snake)
	snake.connect("killed_snake",destroy_snake)
	snake.connect("ate_apple", apple_eaten)
	var title = $InGameUI.get_title()
	title += "s"
	$InGameUI.update_title(title)

@onready var game_paused = false
func apple_eaten():
	print("eaten")
	$Apple.die()
	pause_game()

func pause_game():
	$Tick.stop()
	await get_tree().create_timer(3.0).timeout
	if get_node_or_null("Tick"):
		$Tick.start()

func destroy_snake(having_block, from_id):
	print("snake homicide")
	var snakes = $Snakes.get_children()
	for snake_idx in snakes.size():
		var snake = snakes[snake_idx]
		if snake_idx == from_id:
			continue
		if snake.snake_body.find(having_block):
			snake.die()


var wall_pos = []
func between(num, min, max):
	return num > min and num < max
func generate_walls(num_walls):
	for n in num_walls:
		var rotate = random_rotation()
		var wall_choice = WALL_CHOICES.pick_random()
		var pos = Vector2i(randi_range(1,29), randi_range(3, 15))
		for block in wall_choice:
			var block_pos = rot(rotate, block) + pos
			if between(block_pos.x, 2, 29) and between(block_pos.y, 4, 15):
				wall_pos.push_back(block_pos)
			$TileMap.set_cell(0, block_pos, WALL, Vector2i.ZERO)
func clear_walls():
	for wall in wall_pos:
		$TileMap.set_cell(0, wall, -1)
	wall_pos.clear()

func _ready():
	generate_walls(3)
	spawn_snake()
	spawn_snake()

func _on_tick_timeout():
	$Apple.react_tick()
	if $Snakes.get_child_count() == 0:
		end_round_early()
	for snake in $Snakes.get_children():
		snake.react_tick()


func _on_apple_game_over():
	$RoundClock.stop()
	$Tick.stop()
	$Tick.queue_free()
	$BGM.stop()
	play_sfx("game_over")
	$InGameUI.update_title("Game Over")
	$InGameUI.show_hidden_buttons()
	set_process(false)
	$Apple.queue_free()
	for snake in $Snakes.get_children():
		snake.queue_free()
	for tile in $TileMap.get_used_cells(1):
		$TileMap.set_cell(1, tile, -1)


@onready var points = 0
@onready var round = 1
func end_round_early():
	var extra_points = floor($RoundClock.time_left)
	$RoundClock.stop()
	points += extra_points
	round_end_actions()
	
func round_end_actions():
	# Note: For a fun effect where the blocks just keep filling the screen,
	# Don't clear them
	if randi() % 3 != 0:
		clear_walls()
	$InGameUI.update_title("SNAKE")
	$RoundClock.wait_time = 45.0
	round += 1
	var next_round = randi() % 3
	var walls = (randi() % 5) + 2
	generate_walls(walls)
	
	var snakes = (randi() % 3) + 1
	for sn in snakes:
		spawn_snake()
	$RoundClock.start()
	
func _on_round_clock_timeout():
	pause_game()
	round_end_actions()

func _process(_delta):
	$InGameUI.update_score(points)
	$InGameUI.update_timer(str(floor($RoundClock.time_left)))
	$InGameUI.update_lives($Apple.lives)
	$InGameUI.update_roundct(round)


	

func start_new_game():
	get_tree().reload_current_scene()

func go_to_main():
	get_tree().change_scene_to_file("res://Scenes/MainMenu/main_menu.tscn")
