extends Node

@onready var main = $CanvasLayer/Main
@onready var control = $CanvasLayer/Controls
@onready var credits = $CanvasLayer/Credits

func _ready():
	main.visible = true
	control.visible = false
	credits.visible = false

func start_game():
	get_tree().change_scene_to_file("res://Scenes/MainGame/MainGame.tscn")

# Return to the main menu from any submenu.
func back_to_main():
	main.visible = true
	control.visible = false
	credits.visible = false

func show_controls():
	main.visible = false
	control.visible = true

func show_credits():
	main.visible = false
	credits.visible = true

# Credits link handler
func link_clicked(href):
	OS.shell_open(href)
