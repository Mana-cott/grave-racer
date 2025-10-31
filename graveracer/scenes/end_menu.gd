extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/VBoxContainer/P1TimeLabel.text = "Player 1 Time: %0.2f" % Global.p1_time
	$CanvasLayer/VBoxContainer/P2TimeLabel.text = "Player 2 Time: %0.2f" % Global.p2_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
