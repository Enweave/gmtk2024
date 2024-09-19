extends Node2D

@export var platform: MovingPlatform

@onready var anim_player: AnimationPlayer = %AnimationPlayer
@export var oneshot: bool = true

var _is_triggered: bool = false


func _on_trigger_area_2d_body_entered(body: Node) -> void:
	if _is_triggered:
		return
	_is_triggered = true
	if body is Player or body is BlockBase:
		platform.trigger()
		anim_player.play("down")


func _on_trigger_area_2d_body_exited(body: Node) -> void:
	if oneshot:
		return
	if !_is_triggered:
		return
	_is_triggered = false

	if body is Player or body is BlockBase:
		anim_player.play("up")