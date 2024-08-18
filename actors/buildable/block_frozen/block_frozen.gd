class_name BlockFrozen extends BlockBase

func _ready() -> void:
	super._ready()
	block_type = BlockType.FROZEN

func _init() -> void:
	prefab = preload("res://actors/buildable/block_frozen/block_frozen.tscn")
	UI_Texture_path = "res://assets/spritesheets/props/block_frozen_icon.png"
