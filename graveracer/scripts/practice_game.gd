extends Node3D

@onready var player1 = $Car
@onready var character_portrait = $CanvasLayer/CharacterPortraitRoot/AnimatedSprite2D
@onready var stopwatch_label = $CanvasLayer/StopwatchRoot/StopwatchLabel

@export var chosen_level_scene : PackedScene

var level_instance : Node3D
var finish_line : Node3D
var player_start_pos : Marker3D
var has_winner = false
var time_elapsed = 0.0

func _ready():
	player1.character_name = Global.chosen_character
	player1.max_laps = 3
	player1.LapLabel = $CanvasLayer/LapRoot/LapLabel
	player1.DriftBoostReadyLabel = $CanvasLayer/DriftBoostRoot/DriftBoostReadyLabel
	player1.DriftBoostReadyLabelTimer = $CanvasLayer/DriftBoostRoot/DriftBoostReadyLabelTimer
	character_portrait.play("%s_face" % player1.character_name)
	if chosen_level_scene:
		level_instance = chosen_level_scene.instantiate()
		add_child(level_instance)
	else:
		return
	player_start_pos = level_instance.get_node("FinishLine/SpawnPositions/SP1")
	finish_line = level_instance.get_node("FinishLine")
	if player_start_pos and is_instance_valid(player1):
		player1.global_transform = player_start_pos.global_transform
	if finish_line:
		if finish_line.has_signal("player_crossed"):
			finish_line.player_crossed.connect(_on_player_crossed_finish_line)

func _process(delta: float) -> void:
	time_elapsed += delta
	stopwatch_label.text = "%0.2f" % time_elapsed 
	

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
