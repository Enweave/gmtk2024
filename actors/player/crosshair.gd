extends Node2D

class_name Crosshair

func set_valid(valid: bool) -> void:
	if valid:
		%AnimatedSprite2D.play("valid")
	else:
		%AnimatedSprite2D.play("invalid")
