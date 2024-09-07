extends CollectibleBase

func _ready() -> void:
	collectible_type = CollectibleType.EGG


func _on_area_2d_body_entered(body: Node2D) -> void:
	collect()
	queue_free()
