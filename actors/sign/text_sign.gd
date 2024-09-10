extends Node2D

@export var text: String

func _ready()->void:
	%Label.text = text

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		%Label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		%Label.visible = false
