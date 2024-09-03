extends Node

class_name PlayerState

var egg_count = 0
var cube_count = 0

var selected_slot: BlockBase.BlockType = BlockBase.BlockType.SIMPLE

func reset() -> void:
	selected_slot = BlockBase.BlockType.SIMPLE
	
func switch_slot(_block_type: BlockBase.BlockType) -> void:
	selected_slot = _block_type
