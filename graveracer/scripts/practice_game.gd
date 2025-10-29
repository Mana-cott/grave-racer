extends Node3D

var has_winner = false
@onready var player_start_pos = $FinishLine/StartPosition
@onready var player1 = $Car
@onready var finish_line = $FinishLine

func _ready():
	player1.global_transform = player_start_pos.global_transform
	finish_line.player_crossed.connect(_on_player_crossed_finish_line)
	
func _on_player_crossed_finish_line(player_node : Node3D):
	player_node.current_lap += 1
	if player_node.current_lap >= player_node.max_laps:
		print("WON THE RACE!!!")
