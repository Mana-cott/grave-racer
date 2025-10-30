extends Node3D

# References
@onready var Ball = $Ball
@onready var Car = $Car
@onready var Collider = $Ball/CollisionShape3D
@onready var RightWheel = $"Car/Model/wheel-front-right"
@onready var LeftWheel = $"Car/Model/wheel-front-left"
@onready var CarBody = $Car/Model/kart
@onready var AnimatedSprite = $Car/Model/kart/AnimatedSprite3D
@onready var NitroTimer = $NitroTimer
@onready var DriftTimer = $DriftTimer
@onready var BoostTimer = $BoostTimer

# UI
@onready var HealthLabel = $UI/HBoxContainer/VBoxContainer/HealthLabel
@onready var SpeedLabel = $UI/HBoxContainer/VBoxContainer/SpeedLabel
@onready var BoostLabel = $UI/HBoxContainer/VBoxContainer/BoostLabel
@onready var DriftBoostReadyLabel = $UI/DriftBoostReadyLabel
@onready var DriftBoostReadyLabelTimer = $UI/DriftBoostReadyLabelTimer

# Lap Tracking
@onready var LapLabel = $UI/HBoxContainer/LapLabel
@export var current_lap : int
@export var max_laps : int

# Movement
var current_speed = 0.0
var max_speed = 2500.0
var acceleration_rate = 800.0
var deceleration_rate = 1200.0
var steering = 17.0
var turn_speed = 5
var body_tilt = 30

## Jump
var jump_force = 300
var can_jump = true
var jump_cooldown = 0.18
var is_on_ground = false
var jump_forward_impulse = 120.0

## Input
var speed_input = 0
var rotate_input = 0

## Drift
var Drifting = false
var DriftDirection = 0
var MinimumDrift = 0
var remaining_nitro = 3
var NitroBoost = 2
var Boost = 1
var DriftBoost = 2
var boost_max_speed_multiplier = 1.5

func _ready():
	AnimatedSprite.play("idle")

func _physics_process(delta):
	Car.transform.origin = Ball.transform.origin
	var space_state = get_world_3d().direct_space_state
	var ray_from = Ball.global_position + Vector3.UP * 0.2
	var ray_to = Ball.global_position + Vector3.DOWN * 0.6
	var query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	query.exclude = [Ball]
	var result = space_state.intersect_ray(query)
	is_on_ground = result.size() > 0
	
	# Handle acceleration
	var target_speed = 0.0
	if Input.get_action_strength("accelerate") > 0:
		target_speed = max_speed * Boost
		current_speed = move_toward(current_speed, target_speed, acceleration_rate * delta)
	elif Input.get_action_strength("brake") > 0:
		current_speed = move_toward(current_speed, 0, deceleration_rate * delta)
	else:
		current_speed = move_toward(current_speed, 0, deceleration_rate * 0.5 * delta)
	
	# Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_ground and can_jump:
		# Upward impulse
		Ball.apply_central_impulse(Vector3.UP * jump_force)
		Ball.apply_central_impulse(-Car.global_transform.basis.z * jump_forward_impulse)
		can_jump = false
		await get_tree().create_timer(jump_cooldown).timeout
		can_jump = true
		current_speed = current_speed/2
	
	Ball.apply_central_force(-Car.global_transform.basis.z * current_speed * Boost)
	
func _process(delta):
	speed_input = current_speed  # Update speed_input for UI and other functions
	rotate_input = deg_to_rad(steering) * (Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right"))
	RightWheel.rotation.y = rotate_input
	LeftWheel.rotation.y = rotate_input
	
	if Input.is_action_pressed("nitro"):
		Boost = NitroBoost
		NitroTimer.start()
	
	if Input.is_action_just_pressed("brake") and not Drifting and rotate_input != 0 and speed_input > 0:
		StartDrift()
	
	if Drifting:
		var DriftAmount = 0
		DriftAmount += Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
		DriftAmount *= deg_to_rad(steering*0.55)
		rotate_input = DriftDirection + DriftAmount
		
	if Drifting and (Input.is_action_just_released("brake") or speed_input < 1):
		StopDrift()
	
	if Ball.linear_velocity.length() > 0.75:
		RotateCar(delta)
	
	# UI updates
	SpeedLabel.text = "Speed: %f" % speed_input
	BoostLabel.text = "Nitro: %d" % remaining_nitro
	
	LapLabel.text = "Lap %d/%d" % [current_lap, max_laps]
	
func RotateCar(delta):
	var new_basis = Car.global_transform.basis.rotated(Car.global_transform.basis.y, rotate_input)
	Car.global_transform.basis = Car.global_transform.basis.slerp(new_basis, turn_speed * delta)
	Car.global_transform = Car.global_transform.orthonormalized()
	var t = -rotate_input * Ball.linear_velocity.length() / body_tilt
	CarBody.rotation.z = lerp(CarBody.rotation.z, t, 10 * delta)
	if rotate_input < 0:
		AnimatedSprite.play("turn_left")
	elif rotate_input > 0:
		AnimatedSprite.play("turn_right")
	else:
		AnimatedSprite.play("idle")
		

func StartDrift():
	Drifting = true
	MinimumDrift = false
	DriftDirection = rotate_input
	
	DriftTimer.start()
	
func StopDrift():
	if MinimumDrift:
		Boost = DriftBoost
		max_speed *= boost_max_speed_multiplier
		BoostTimer.start()
	Drifting = false
	MinimumDrift = false

func _on_drift_timer_timeout():
	if Drifting:
		MinimumDrift = true
		DriftBoostReadyLabel.visible = true
		DriftBoostReadyLabelTimer.start()

func _on_boost_timer_timeout():
	Boost = 1.0
	max_speed = 2000.0
	

func _on_drift_boost_ready_label_timer_timeout():
	DriftBoostReadyLabel.visible = false

func _on_nitro_timer_timeout():
	Boost = 1

func increment_lap():
	current_lap += 1
