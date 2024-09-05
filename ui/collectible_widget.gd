extends Control
class_name CollectibleWidget

func _ready() -> void:
	%Value.text = "0"


func set_texture(_texture_path: String) -> void:
	%TextureRect.texture = load(_texture_path)


func update_value(_value: int) -> void:
	%Value.text = str(_value)
