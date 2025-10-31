extends Node3D

@export var car : PackedScene

func _on_death_zone_body_entered(body):
	var parent = body.get_parent()
	if parent.is_in_group("player"):
		print("ENTERED DEATH ZONE")
		body.apply_central_impulse(Vector3.UP * 5000)
		body.apply_central_impulse(-body.global_transform.basis.z * -300)
