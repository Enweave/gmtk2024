extends Node2D

class_name GridCursor

var grid_size: int = 16
var _half_grid_size: int
var polygon2d: Polygon2D
var color_unoccupied: Color = Color(1, 1, 1, 0.3)
var color_pickable: Color = Color(0, 1, 0, 0.3)
var color_out_of_range: Color = Color(1, 0, 0, 0.3)

func rebuild_rectangle(_grid_size: int) -> void:
	polygon2d = %Polygon2D
	grid_size = _grid_size
	_half_grid_size = grid_size / 2
	var rect: Rect2 = Rect2(Vector2(-_half_grid_size, -_half_grid_size), Vector2(grid_size, grid_size))
	var points: Array[Vector2] = [
		Vector2(rect.position.x, rect.position.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x, rect.position.y)
	]
	polygon2d.polygon = points
	

func _update_display(_in_range: bool, _unoccupied: bool, _pickable: bool) -> void:
	if _in_range:
		if _pickable:
			polygon2d.color = color_pickable
			return
		else:
			if _unoccupied:
				polygon2d.color = color_unoccupied
				return
			polygon2d.color = color_out_of_range
	else:
		polygon2d.color = color_out_of_range

func snap_to_grid(_position: Vector2, _in_range: bool, _unoccupied: bool, _pickable: bool, _grid_origin: Vector2 = Vector2.ZERO) -> Vector2:
	# snaps to grid and returns center
	var x: float = (int(_position.x - _grid_origin.x) / grid_size) * grid_size + (sign(_position.x)*_half_grid_size) + _grid_origin.x
	var y: float = (int(_position.y - _grid_origin.y) / grid_size) * grid_size + (sign(_position.y)*_half_grid_size) + _grid_origin.y
	
	global_position = Vector2(x, y)

	_update_display(_in_range, _unoccupied, _pickable)
	
	return Vector2(x, y)
