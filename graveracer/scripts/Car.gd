extends Node3D

@onready var Ball = $Ball
@onready var Car = $Car
@onready var Collider = $Ball/CollisionShape3D
@onready var RightWheel = $"Car/Model/wheel-front-right"
@onready var LeftWheel = $"Car/Model/wheel-front-left"
@onready var CarBody = $Car/Model/kart
@onready var AnimatedSprite = $Car/Model/kart/AnimatedSprite3D
@onready var DriftTimer = $DriftTimer
@onready var BoostTimer = $BoostTimer
@onready var SpeedLabel = $UI/VBoxContainer/SpeedLabel
@onready var DriftBoostReadyLabel = $UI/DriftBoostReadyLabel
@onready var DriftBoostReadyLabelTimer = $UI/DriftBoostReadyLabelTimer

var acceleration = 1000.0 #70.0
var steering = 17.0
var turn_speed = 5
var body_tilt = 30
var jump_force = 300

var speed_input = 0
var rotate_input = 0

var Drifting = false
var DriftDirection = 0
var MinimumDrift = 0
var Boost = 1
var DriftBoost = 4#1.75

func _ready():
	AnimatedSprite.play("idle")

func _physics_process(delta):
	Car.transform.origin = Ball.transform.origin
	Ball.apply_central_force(-Car.global_transform.basis.z * speed_input * Boost)
	
func _process(delta):
	speed_input = (Input.get_action_strength("accelerate") - Input.get_action_strength("break")) * acceleration
	rotate_input = deg_to_rad(steering) * (Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right"))
	RightWheel.rotation.y = rotate_input
	LeftWheel.rotation.y = rotate_input
	
	if Input.is_action_just_pressed("drift") and not Drifting and rotate_input != 0 and speed_input > 0:
		StartDrift()
	
	if Drifting:
		var DriftAmount = 0
		DriftAmount += Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
		DriftAmount *= deg_to_rad(steering*0.55)
		rotate_input = DriftDirection + DriftAmount
		
	if Drifting and (Input.is_action_just_released("drift") or speed_input < 1):
		StopDrift()
	
	if Ball.linear_velocity.length() > 0.75:
		RotateCar(delta)
		
	SpeedLabel.text = "Speed: %f" % speed_input
	
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


func _on_drift_boost_ready_label_timer_timeout():
	DriftBoostReadyLabel.visible = false
