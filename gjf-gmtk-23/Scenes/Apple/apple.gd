extends Node2D
const APPLE=0
const SNAKE=1
const WALL=2
@onready var direction = Vector2i(0, 0)
@onready var tilemap = get_parent().get_child(0)
@onready var apple_pos = Vector2i(5,5)

# Called when the node enters the scene tree for the first time.
func _ready():
	draw_apple()

func find_new_pos():
	var new_pos = Vector2i(randi_range(1,29),randi_range(3,15))
	if tilemap.get_cell_source_id(1, new_pos) != -1:
		new_pos = find_new_pos()
	return new_pos
# Only cardinal directions are allowed; best get tappin'
func _input(_ev):
	if Input.is_action_pressed("ui_up"):
		direction = Vector2i(0,-1)
	elif Input.is_action_pressed("ui_down"):
		direction = Vector2i(0,1)
	elif Input.is_action_pressed("ui_left"):
		direction = Vector2i(-1,0)
	elif Input.is_action_pressed("ui_right"):
		direction = Vector2i(1,0)


func clear_apple():
	tilemap.set_cell(1,apple_pos)
func draw_apple():
	tilemap.set_cell(1, apple_pos, APPLE, Vector2i.ZERO)
	
func move():
	# Wall Check for next update
	if tilemap.get_cell_source_id(0, apple_pos + direction) == WALL:
		direction = Vector2i.ZERO
	elif tilemap.get_cell_source_id(1, apple_pos + direction) == SNAKE:
		die()

	apple_pos.x += direction.x
	apple_pos.y += direction.y

@onready var lives = 3
signal game_over
func die():
	lives -= 1
	if lives <= 0:
		emit_signal("game_over")
	else:
		apple_pos = find_new_pos()
	
func react_tick():
	clear_apple()
	move()
	draw_apple()
