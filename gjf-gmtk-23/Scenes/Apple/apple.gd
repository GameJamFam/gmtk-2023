extends Node2D
@export var speed: float # 125 feels right
@onready var direction = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Only cardinal directions are allowed; best get tappin'
func read_input():
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
		direction.x = 0
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
		direction.x = 0
	elif Input.is_action_pressed("ui_left"):
		direction.x = -1
		direction.y = 0
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
		direction.y = 0
	
func move(d):
	position.x += direction.x * d * speed
	position.y += direction.y * d * speed
	if direction.x != 0 or direction.y != 0:
		print(direction)
		print(position)
	
func _process(delta):
	read_input()
	move(delta)
