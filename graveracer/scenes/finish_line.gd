extends Node3D

@onready var animated_sprite = $AnimatedSprite3D
signal player_crossed(player_node: Node3D)

var triggered_players: Array[Node3D] = []

func _ready():
	animated_sprite.play("default")

func _on_area_3d_body_entered(body):
	var parent = body.get_parent()
	if parent.is_in_group("player") and parent not in triggered_players:
		triggered_players.append(parent)
		player_crossed.emit(parent)

	# Clear laps
	await get_tree().create_timer(1.0).timeout
	triggered_players.erase(body)
