extends RigidBody2D

class_name Block

@onready var anim_player = %AnimationPlayer
var is_being_removed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("appear")
	
	
func _remove() -> void:
	await get_tree().create_timer(0.5).timeout
	queue_free()


func remove() -> int:
	if !is_being_removed:
		is_being_removed = true
		anim_player.play("disappear")
		_remove()
		return 1
	return 0
