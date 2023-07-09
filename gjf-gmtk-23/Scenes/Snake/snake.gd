extends Node2D
"""
The snake AI is fairly simple.
1. It is driven by insatiable hunger for the apple. Its first though is always the next meal.
2. It will avoid eating other snakes at all costs (too stringy for its taste).
3. It will try to avoid walls, but if there are no other options, it will run into them.
4. It will try to avoid eating itself, but if there are no other options, it will.
   The exception to this is its own tail (the last section). If the fastest route to the apple is
   through its own tail, the snake will be blinded by the thought of an apple and ouroboros itself.
"""
const APPLE = 0
const SNAKE = 1
const WALL = 2

const START_LENGTH = 3

@onready var snake_body = []
@onready var tilemap = get_parent().get_parent().get_child(0)
@onready var direction = Vector2.ZERO

# It's not pretty, but at least it's O(1) 
func snake_tile(part, orientation):
	match part:
		"head":
			match orientation:
				"up":
					return Vector2i(1,4)
				"down":
					return Vector2i(0,3)
				"left":
					return Vector2i(1,3)
				"right":
					return Vector2i(0,4)
		"body":
			match orientation:
				"horz":
					return Vector2i(1,2)
				"vert":
					return Vector2i(0, 1)
		"curve":
			match orientation:
				"ur": # up right
					return Vector2i(0,0)
				"ul": # up left
					return Vector2i(1,0)
				"lr":
					return Vector2i(1,1)
				"ll":
					return Vector2i(0,2)
		"tail":
			match orientation:
				"up":
					return Vector2i(1,6)
				"down":
					return Vector2i(0,5)
				"left":
					return Vector2i(1,5)
				"right":
					return Vector2i(0,6)

func relative_to(i:Vector2i,j:Vector2i): # Return relative position
	var relation = i - j
	match relation:
		Vector2i(-1,0):
			return 'left'
		Vector2i(1,0):
			return 'right'
		Vector2i(0,1):
			return 'down'
		Vector2i(0,-1):
			return 'up'
		_: # How the fuck this even happens IDK, sometimes the snake just goes neckless
			return 'left'

func relative_curve(p:Vector2i, n:Vector2i):
	# Convert to cartesian plane
	var prev = Vector2i(p.x, -p.y)
	var next = Vector2i(n.x, -n.y)
	
	# Check if next block is a -90 degree rotation from the previous block
	#   if so, we subtract the difference of their inverted positions
	#                 from the difference in their relative positions 
	#          to get the quadrant that connects them.
	# Otherwise, we just need to reverse the order.
	var relation = null
	if Vector2i(prev.y, -prev.x) == next:
		relation = (prev - next) - (next - prev)
	else:
		relation = (next - prev) - (prev - next)
	match relation:
		Vector2i(-2,-2):
			return 'lr'
		Vector2i(-2, 2):
			return 'll'
		Vector2i(2, 2):
			return 'ul'
		Vector2i(2, -2):
			return 'ur'
		
func snake_relation(i,j):
	return relative_to(snake_body[i], snake_body[j])
	
func choose_spawn():
	var start = Vector2i(randi_range(1,30), randi_range(3,15))
	if tilemap.get_cell_source_id(0, start) != -1:
		return choose_spawn()
	return start

func choose_adj_empty(head):
	if tilemap.get_cell_source_id(1, head + Vector2i(-1,0)) == 1: # face right
		return Vector2i(head.x - 1, head.y)
	elif tilemap.get_cell_source_id(1, head + Vector2i(0,-1)) == 1: # face down
		return Vector2i(head.x, head.y - 1)
	elif tilemap.get_cell_source_id(1, head + Vector2i(1,0)) == 1: # face left
		return Vector2i(head.x + 1, head.y)
	else:															# face up
		return Vector2i(head.x, head.y + 1)

func _ready():
	var head = choose_spawn()
	var body1 = choose_adj_empty(head)
	var body2 = choose_adj_empty(body1)
	snake_body = [head, body1, body2]
	draw_snake()

func clear_snake():
	for cell in snake_body:
		tilemap.set_cell(1, cell, -1)
		
func draw_snake():
	#for block in snake_body:
	#	tilemap.set_cell(1,block, SNAKE, snake_tile("body","vert"))
	for block_idx in snake_body.size():
		var block = snake_body[block_idx]
		if block_idx == 0:
			tilemap.set_cell(1, block, SNAKE, snake_tile("head", snake_relation(0,1)))
		elif block_idx == snake_body.size() - 1:
			tilemap.set_cell(1, block, SNAKE, snake_tile("tail", snake_relation(-1, -2))) # rindex
		else:
			var prev_block = snake_body[block_idx + 1] - block
			var next_block = snake_body[block_idx - 1] - block
			
			if prev_block.x == next_block.x:
				tilemap.set_cell(1, block, SNAKE, snake_tile("body", "horz"))
			elif prev_block.y == next_block.y:
				tilemap.set_cell(1, block, SNAKE, snake_tile("body", "vert"))
			else:
				tilemap.set_cell(1, block, SNAKE, snake_tile("curve", relative_curve(prev_block, next_block)))

@onready var paused = false
func pause(state):
	paused = state
func react_tick():
	clear_snake()
	if dead or paused:
		return
	direction = choose_direction()
	move()
	if snake_body.size() < START_LENGTH:
		add_body_segment()
	draw_snake()


func choose_direction():
	var forbidden = (snake_body[0] - snake_body[1]) * -1 # Backwards
	# 1. Avoid walls
	# 2. Avoid snakes
	# 3. Search for apple
	var moves = []
	match forbidden:
		Vector2i(1,0): # moving leftwards
			moves = [Vector2i(0,-1),Vector2i(-1,0),Vector2i(0,1)]
		Vector2i(-1,0): # moving rightwards
			moves = [Vector2i(1,0),Vector2i(0,-1),Vector2i(0,1)]
		Vector2i(0,1): # moving upwards
			moves = [Vector2i(1,0),Vector2i(0,-1),Vector2i(-1,0)]
		Vector2i(0,-1): # moving downwards
			moves = [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1)]
	
	var apple = apple_direction()
	if apple != forbidden:
		return apple
	return moves[randi() % (moves.size() - 1)]

signal ate_apple
func apple_direction():
	var apple_loc = tilemap.get_used_cells_by_id(1,APPLE)
	if apple_loc.size() == 0:
		emit_signal("ate_apple")
		return Vector2i.ZERO
	var diff = apple_loc[0] - snake_body[0]
	if diff == Vector2i.ZERO:
		add_body_segment()
		emit_signal("ate_apple")
		return Vector2i.ZERO
	elif abs(diff.x) > abs(diff.y):
		return Vector2i(diff.x / abs(diff.x), 0)
	else:
		return Vector2i(0, diff.y / abs(diff.y))
	
func choose_rand_dir(moves):
	return moves[randi() % (moves.size() - 1)]

func move():
	var next = snake_body[0] + direction
	if tilemap.get_cell_source_id(0, next) == WALL:
		die(true)
	if next == snake_body[-1]:
		ouroboros()
	elif tilemap.get_cell_source_id(1, next) == SNAKE:
		kill_other_snake_or_die(next)
	else:
		snake_body.insert(0,next)
		snake_body.pop_back()

var snake_num = -1
signal killed_snake (block, id)
func kill_other_snake_or_die(block):
	if snake_body.rfind(block,-2):
		die(true)
	else:
		emit_signal("killed_snake", block, snake_num)

func add_body_segment():
	var body_copy = snake_body.slice(0, snake_body.size() - 1)
	var new_head = choose_adj_empty(body_copy[0])
	body_copy.insert(0, new_head)
	snake_body = body_copy

signal ouroboros_points
func ouroboros():
	emit_signal("ouroboros_points")
	die(true)

@onready var dead = false
func die(points=false):
	if points:
		get_parent().get_parent().add_points(50)
	clear_snake()
	dead = true
	await get_tree().create_timer(1).timeout
	queue_free()
