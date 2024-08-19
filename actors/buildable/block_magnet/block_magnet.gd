class_name BlockMagnet extends BlockBase

var magnet_strength: float = -500.
var magnet_time_step: float = 0.05
@onready var area: Area2D = %Area2D

func pull_blocks() -> void:
	var bodies: Array[Node2D] = area.get_overlapping_bodies()
	bodies.erase(self)
	for body in bodies:
		if body is BlockBase:
			var block: BlockBase = body as BlockBase
			var direction: Vector2 = (block.global_position - global_position).normalized()
			block.apply_central_force(direction * magnet_strength)

			
func _ready() -> void:
	super._ready()
	block_type = BlockType.MAGNET
	var timer = Timer.new()
	timer.set_wait_time(magnet_time_step)
	timer.set_one_shot(false)
	timer.connect("timeout", pull_blocks)
	self.add_child(timer)
	timer.start()
	

func _init() -> void:
	prefab = preload("res://actors/buildable/block_magnet/block_magnet.tscn")
	UI_Texture_path = "res://assets/spritesheets/props/block_magnet_icon.png"