extends RigidBody2D

class_name Block

@onready var anim_player = %AnimationPlayer
var is_being_removed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("appear")
	
	
func remove() -> void:
	if !is_being_removed:
		is_being_removed = true
		anim_player.play("disappear")
		await get_tree().create_timer(0.5).timeout
		queue_free()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
