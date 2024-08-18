extends RefCounted

class_name Inventory

var slots_map: Dictionary = {
	BlockBase.BlockType.SIMPLE: InventorySlot.new(BlockSimple),
	BlockBase.BlockType.FROZEN: InventorySlot.new(BlockFrozen),
}

var selected_slot: InventorySlot = slots_map[BlockBase.BlockType.SIMPLE]

func switch_slot(_block_type: BlockBase.BlockType) -> void:
	print("Switching to ", _block_type)
	for slot in slots_map.values():
		slot.is_selected = false
	slots_map[_block_type].is_selected = true

func _process(_delta: float) -> void:
	if Input.is_action_pressed("switch_slot_1"):
		switch_slot(BlockBase.BlockType.SIMPLE)
	elif Input.is_action_pressed("switch_slot_2"):
		switch_slot(BlockBase.BlockType.FROZEN)

		