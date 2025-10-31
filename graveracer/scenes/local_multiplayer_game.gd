extends Node3D

@onready var player1 = $GridContainer/SubViewportContainer/SubViewport/Car
@onready var player2 = $GridContainer/SubViewportContainer2/SubViewport/LocalCar
@onready var character_portrait_1 = $GridContainer/SubViewportContainer/SubViewport/CanvasLayer/CharacterPortraitRoot/AnimatedSprite2D
@onready var character_portrait_2 = $GridContainer/SubViewportContainer2/SubViewport/CanvasLayer/CharacterPortraitRoot/AnimatedSprite2D
@onready var p1_stopwatch_label = $GridContainer/SubViewportContainer/SubViewport/CanvasLayer/StopwatchRoot/StopwatchLabel
@onready var p2_stopwatch_label = $GridContainer/SubViewportContainer2/SubViewport/CanvasLayer/StopwatchRoot/StopwatchLabel

@export var chosen_level_scene : PackedScene

var level_instance : Node3D
var finish_line : Node3D
var player1_start_pos : Marker3D
var player2_start_pos : Marker3D
var has_winner = false
var time_elapsed = 0.0

var is_p1_done = false
var is_p2_done = false
var p1_time
var p2_time

func _ready():
	player1.character_name = Global.local_chosen_character1
	player2.character_name = Global.local_chosen_character2
	player1.max_laps = 3
	player2.max_laps = 3
	player1.LapLabel = $GridContainer/SubViewportContainer/SubViewport/CanvasLayer/LapRoot/LapLabel
	player2.LapLabel = $GridContainer/SubViewportContainer2/SubViewport/CanvasLayer/LapRoot/LapLabel
	player1.DriftBoostReadyLabel = $GridContainer/SubViewportContainer/SubViewport/CanvasLayer/DriftBoostRoot/DriftBoostReadyLabel
	player2.DriftBoostReadyLabel = $GridContainer/SubViewportContainer2/SubViewport/CanvasLayer/DriftBoostRoot/DriftBoostReadyLabel
	player1.DriftBoostReadyLabelTimer = $GridContainer/SubViewportContainer/SubViewport/CanvasLayer/DriftBoostRoot/DriftBoostReadyLabelTimer
	player2.DriftBoostReadyLabelTimer = $GridContainer/SubViewportContainer2/SubViewport/CanvasLayer/DriftBoostRoot/DriftBoostReadyLabelTimer
	
	character_portrait_1.play("%s_face" % player1.character_name)
	character_portrait_2.play("%s_face" % player2.character_name)
	
	if chosen_level_scene:
		level_instance = chosen_level_scene.instantiate()
		add_child(level_instance)
	else:
		return
	player1_start_pos = level_instance.get_node("FinishLine/SpawnPositions/SP1")
	player2_start_pos = level_instance.get_node("FinishLine/SpawnPositions/SP2")
	finish_line = level_instance.get_node("FinishLine")
	if player1_start_pos and is_instance_valid(player1):
		player1.global_transform = player1_start_pos.global_transform
	if player2_start_pos and is_instance_valid(player2):
		player2.global_transform = player2_start_pos.global_transform
	if finish_line:
		if finish_line.has_signal("player_crossed"):
			finish_line.player_crossed.connect(_on_player_crossed_finish_line)

func _process(delta: float) -> void:
	if player1.current_lap >= 3 and not is_p1_done:
		is_p1_done = true
		p1_time = time_elapsed
		Global.p1_time = p1_time
	if player2.current_lap >= 3 and not is_p2_done:
		is_p2_done = true
		p2_time = time_elapsed
		Global.p2_time = p2_time
	if(!is_p1_done || !is_p2_done):
		time_elapsed += delta
		if(!is_p1_done): p1_stopwatch_label.text = "%0.2f" % time_elapsed 
		if(!is_p2_done): p2_stopwatch_label.text = "%0.2f" % time_elapsed 
	else:
		get_tree().change_scene_to_file("res://scenes/end_menu.tscn")
	
func _on_player_crossed_finish_line(player_node : Node3D):
	if not is_instance_valid(player_node):
		return
	call_deferred("_handle_lap_update", player_node)

func _handle_lap_update(player_node : Node3D):
	if not is_instance_valid(player_node):
		return
	player_node.increment_lap()
	if player_node.current_lap >= player_node.max_laps and not has_winner:
		has_winner = true
		declare_winner(player_node)

func declare_winner(player_node: Node3D):
	print("%s WON THE RACE!!!" % player_node.name)
