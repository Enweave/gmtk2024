extends Node2D

@export var platform: MovingPlatform
@onready var anim_player : AnimationPlayer = %AnimationPlayer

func _on_trigger_area_2d_body_entered(body: Node) -> void:
	if body is Player or body is BlockBase:
		platform.trigger()
		anim_player.play("down")
		
func _on_trigger_area_2d_body_exited(body: Node) -> void:
	if body is Player or body is BlockBase:
		anim_player.play("up")