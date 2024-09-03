extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	GlobalPlayerState.egg_count +=1
	queue_free()
