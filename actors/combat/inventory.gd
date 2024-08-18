extends RefCounted

class_name Inventory

var slots_map: Dictionary = {
	BlockBase.BlockType.SIMPLE: InventorySlot.new(BlockSimple.new()),
	BlockBase.BlockType.FROZEN: InventorySlot.new(BlockFrozen.new()),
}

var selected_slot: InventorySlot = slots_map[BlockBase.BlockType.SIMPLE]

func get_slot(_block_type: BlockBase.BlockType) -> InventorySlot:
	return slots_map[_block_type]

func _init() -> void:
	switch_slot(BlockBase.BlockType.SIMPLE)

func switch_slot(_block_type: BlockBase.BlockType) -> void:
	print("Switching to ", _block_type)
	for slot in slots_map.values():
		slot.is_selected = false
	slots_map[_block_type].is_selected = true
	selected_slot = slots_map[_block_type]
	