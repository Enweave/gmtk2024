extends RigidBody2D
class_name BlockBase

enum BlockType {
	SIMPLE,
	FROZEN,
	MAGNET,
	STICKY,
	HOT
}
var UI_Texture_path: String = ""

var prefab: PackedScene

@onready var anim_player = %AnimationPlayer

var disappear_time: float = 0.5
var is_being_removed: bool = false
var block_type: BlockType = BlockType.SIMPLE


func _ready() -> void:
	anim_player.play("appear")


func _remove() -> void:
	self.freeze = true
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.disabled = true
	await get_tree().create_timer(disappear_time).timeout
	queue_free()


func pickup() -> int:
	if !is_being_removed:
		is_being_removed = true
		anim_player.play("disappear")
		_remove()
		return 1
	return 0
