extends Control

class_name SlotWidget

var inventory_slot: InventorySlot

func set_texture(_texture: Texture) -> void:
	var _texture_rect: TextureRect = %TextureRect
	_texture_rect.texture = _texture

func set_quantity(_quantity: int) -> void:
	var _quantity_label: Label = %Value
	_quantity_label.text = str(_quantity)