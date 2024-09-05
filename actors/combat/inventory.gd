extends RefCounted
class_name Inventory
signal slot_switched
signal blocks_full
signal collectible_added

var player_state: PlayerState
var _selected_slot_index: int = 0
var _last_slot_index: int = 3

# map of collectible amount { CollectibleBase.CollectibleType: int }
var collectibles: Dictionary # 

func _add_collectible_amount(_type: CollectibleBase.CollectibleType, _amount: int) -> void:
	if collectibles.has(_type):
		collectibles[_type] += _amount
	else:
		collectibles[_type] = _amount


func add_collectible(_type: CollectibleBase.CollectibleType) -> void:
	_add_collectible_amount(_type, 1)
	collectible_added.emit()

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


func get_block_type_from_index(_index: int) -> BlockBase.BlockType:
	for slot in slots_map.keys():
		if slot == _index:
			return slot
	return BlockBase.BlockType.SIMPLE


func _init(_player_state: PlayerState) -> void:
	player_state = _player_state
	collectibles = {}
	_last_slot_index = slots_map.size() - 1
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

	_selected_slot_index = int(_block_type)


func next_slot():
	var next_slot_index: int = _selected_slot_index + 1
	if next_slot_index > _last_slot_index:
		next_slot_index = 0
	
	switch_slot(get_block_type_from_index(next_slot_index))


func previous_slot():
	var previous_slot_index: int = _selected_slot_index - 1
	if previous_slot_index < 0:
		previous_slot_index = _last_slot_index

	switch_slot(get_block_type_from_index(previous_slot_index))
