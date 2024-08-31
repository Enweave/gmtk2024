extends RefCounted

class_name Inventory
signal slot_switched
signal blocks_full

var player_state: PlayerState

func _on_blocks_full() -> void:
	blocks_full.emit()

var slots_map: Dictionary = {
	BlockBase.BlockType.SIMPLE: InventorySlot.new(BlockSimple.new()),
	BlockBase.BlockType.FROZEN: InventorySlot.new(BlockFrozen.new()),
	BlockBase.BlockType.MAGNET: InventorySlot.new(BlockMagnet.new()),
	BlockBase.BlockType.STICKY: InventorySlot.new(BlockSticky.new())
}

var selected_slot: InventorySlot = slots_map[BlockBase.BlockType.SIMPLE]

func get_slot(_block_type: BlockBase.BlockType) -> InventorySlot:
	return slots_map[_block_type]

func _init(_player_state: PlayerState) -> void:
	player_state = _player_state
	switch_slot(player_state.selected_slot, false)
	for slot in slots_map.values():
		slot.blocks_full.connect(_on_blocks_full)

func switch_slot(_block_type: BlockBase.BlockType, _update_state: bool = true) -> void:
	for slot in slots_map.values():
		slot.is_selected = false
	slots_map[_block_type].is_selected = true
	selected_slot = slots_map[_block_type]
	slot_switched.emit()
	if _update_state:
		player_state.switch_slot(_block_type)