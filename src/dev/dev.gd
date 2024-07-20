extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AMContainer.start()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		$AMContainer.level += 1;
	if Input.is_action_just_pressed("ui_cancel"):
		$AMContainer.level -= 1;
