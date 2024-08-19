extends RefCounted

class_name Inventory
signal slot_switched


var slots_map: Dictionary = {
	BlockBase.BlockType.SIMPLE: InventorySlot.new(BlockSimple.new()),
	BlockBase.BlockType.FROZEN: InventorySlot.new(BlockFrozen.new()),
	BlockBase.BlockType.MAGNET: InventorySlot.new(BlockMagnet.new())
}

var selected_slot: InventorySlot = slots_map[BlockBase.BlockType.SIMPLE]

func get_slot(_block_type: BlockBase.BlockType) -> InventorySlot:
	return slots_map[_block_type]

func _init() -> void:
	switch_slot(BlockBase.BlockType.SIMPLE)

func switch_slot(_block_type: BlockBase.BlockType) -> void:
	for slot in slots_map.values():
		slot.is_selected = false
	slots_map[_block_type].is_selected = true
	selected_slot = slots_map[_block_type]
	slot_switched.emit()
	