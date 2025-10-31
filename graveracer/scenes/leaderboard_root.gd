extends Control

@onready var Portrait1 = $VBoxContainer/HBoxContainer/Portrait
@onready var Portrait2 = $VBoxContainer/HBoxContainer2/Portrait
@onready var Portrait3 = $VBoxContainer/HBoxContainer3/Portrait

func _ready():
	Portrait1.play("goosha_face")
	Portrait2.play("pumkin_face")
	Portrait3.play("kombi_face")
