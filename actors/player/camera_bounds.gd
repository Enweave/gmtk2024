@tool
extends Node2D

class_name CameraBounds

@export var width: int = 1280:
	set(value):
		width = value
		update_bounds()

@export var height: int = 720:
	set(value):
		height = value
		update_bounds()
	
func update_bounds():
	%CameraBounds.shape['size'] = Vector2(width, height)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in get_tree().get_nodes_in_group("player"):
		var left := int(global_position.x - width / 2)
		var top := int(global_position.y - height / 2)
		var right := int(global_position.x + width / 2)
		var bottom := int(global_position.y + height / 2)
		
		var player: Player = p as Player
		player.update_camera_bounds(left, top, right, bottom)
