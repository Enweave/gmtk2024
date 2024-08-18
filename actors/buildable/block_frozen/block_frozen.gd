class_name BlockFrozen extends BlockBase

func _ready() -> void:
	super._ready()
	block_type = BlockType.FROZEN

func _init() -> void:
	prefab = preload("res://actors/buildable/block_frozen/block_frozen.tscn")