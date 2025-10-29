extends Node3D
@onready var animated_sprite = $AnimatedSprite3D
signal player_crossed(player_node: Node3D)

func _ready():
	animated_sprite.play("default")


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_crossed.emit(body)
