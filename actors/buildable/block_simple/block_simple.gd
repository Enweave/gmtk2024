class_name BlockSimple extends BlockBase

func _ready() -> void:
	super._ready()
	
	block_type = BlockType.SIMPLE

func _init() -> void:
	prefab = preload("res://actors/buildable/block_simple/block_simple.tscn")
	UI_Texture_path = "res://assets/spritesheets/props/block.png"
