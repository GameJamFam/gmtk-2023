extends Control

func update_score(sc):
	var scoretext = $CanvasLayer/PanelContainer/HBoxContainer/ScoreBox/VBoxContainer/Score
	scoretext.text = str(sc)

func update_lives(lv):
	var livestext = $CanvasLayer/PanelContainer/HBoxContainer/LivesBox/VBoxContainer/Lives
	livestext.text = str(lv)

func update_timer(tm):
	var timertext = $CanvasLayer/PanelContainer/HBoxContainer/TimerBox/VBoxContainer/Timer
	timertext.text = str(tm)
	
func update_roundct(ct):
	var rnd = $CanvasLayer/PanelContainer/HBoxContainer/RoundNumBox/VBoxContainer/Rounds
	rnd.text = str(ct)

func update_title(title):
	var titletext = $CanvasLayer/PanelContainer/HBoxContainer/Title
	titletext.text = title

func get_title():
	var titletext = $CanvasLayer/PanelContainer/HBoxContainer/Title
	return titletext.text

func show_hidden_buttons():
	$CanvasLayer/PanelContainer/HBoxContainer/GameOver.visible = true

signal restart
signal main_menu

func restart_game():
	emit_signal("restart")

func mainmenu():
	emit_signal("main_menu")
