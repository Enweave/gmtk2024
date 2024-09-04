extends CollectibleBase


func _on_area_2d_body_entered(body: Node2D) -> void:
	collect()
	queue_free()
