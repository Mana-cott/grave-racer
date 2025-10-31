extends Control

var first_chosen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pumkin_button_pressed():
	if Global.local_multiplayer:
		if !first_chosen:
			Global.local_chosen_character1 = "pumkin"
			first_chosen = true
		else:
			Global.local_chosen_character2 = "pumkin"
			get_tree().change_scene_to_file("res://scenes/local_multiplayer_game.tscn")
	else:
		Global.chosen_character = "pumkin"
		get_tree().change_scene_to_file("res://scenes/practice_game.tscn")

func _on_goosha_button_pressed():
	if Global.local_multiplayer:
		if !first_chosen:
			Global.local_chosen_character1 = "goosha"
			first_chosen = true
		else:
			Global.local_chosen_character2 = "goosha"
			get_tree().change_scene_to_file("res://scenes/local_multiplayer_game.tscn")
	else:
		Global.chosen_character = "goosha"
		get_tree().change_scene_to_file("res://scenes/practice_game.tscn")

func _on_kombi_button_pressed():
	if Global.local_multiplayer:
		if !first_chosen:
			Global.local_chosen_character1 = "kombi"
			first_chosen = true
		else:
			Global.local_chosen_character2 = "kombi"
			get_tree().change_scene_to_file("res://scenes/local_multiplayer_game.tscn")
	else:
		Global.chosen_character = "kombi"
		get_tree().change_scene_to_file("res://scenes/practice_game.tscn")
