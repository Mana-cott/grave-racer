extends Node3D

@onready var player_start_pos = $FinishLine/StartPosition
@onready var player1 = $Car
@onready var finish_line = $FinishLine

var has_winner = false

func _ready():
	player1.global_transform = player_start_pos.global_transform
	finish_line.player_crossed.connect(_on_player_crossed_finish_line)
	
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
