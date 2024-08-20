extends Node2D

class_name Explosion

func _ready() -> void:
	%AnimatedSprite2D.play("default")
	%AnimatedSprite2D.connect("animation_finished", _on_animation_finished)
	%RandomPlayer.play_random_sound()
	pass # Replace with function body.

func _on_animation_finished() -> void:
	queue_free()

