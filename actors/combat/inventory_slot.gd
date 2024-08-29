extends RefCounted

class_name InventorySlot

signal quantity_changed

var block: BlockBase = null
var MAX_BLOCKS: int = 3
var current_blocks: int = 0
var is_selected: bool = false
var unlocked: bool = false

func get_texture() -> Texture:
	return load(block.UI_Texture_path)

func _init(_block_class: BlockBase, _current_blocks: int = 0) -> void:
	block = _block_class
	current_blocks = min(_current_blocks, MAX_BLOCKS)
	if current_blocks > 0:
		unlocked = true

func can_add_block(_quantity: int = 1) -> bool:
	return (current_blocks+_quantity) < MAX_BLOCKS	

func add_block(_quantity: int = 1) -> void:
	unlocked = true
	current_blocks += _quantity
	quantity_changed.emit()
	
func can_remove_block(_quantity: int = 1) -> bool:
	return (current_blocks-_quantity) >= 0
	
func remove_block(_quantity: int = 1) -> void:
	current_blocks -= _quantity
	quantity_changed.emit()
