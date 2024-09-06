@tool
extends Node2D

class_name HiddenWallSensor
var fade_duration: float = 0.5

@export var tile_map: TileMap
@export var abyss: Polygon2D

@export var width: int = 1280:
	set(value):
		width = value
		update_bounds()

@export var height: int = 720:
	set(value):
		height = value
		update_bounds()

func update_bounds():
	%Bounds.shape['size'] = Vector2(width, height)
	

func _on_area_2d_body_entered(_body):
	if _body is Player and tile_map != null:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(tile_map, 'modulate:a', 0, fade_duration)
		if abyss!=null:
			var tween2: Tween = get_tree().create_tween()
			tween2.tween_property(abyss, 'modulate:a', 0, fade_duration)
	
#func _on_area_2d_body_exited(_body):
	#if _body is Player and tile_map != null:
		#var tween: Tween = get_tree().create_tween()
		#tween.tween_property(tile_map, 'modulate:a', 1, fade_duration)
