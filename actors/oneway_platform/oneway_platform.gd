@tool
extends Node2D

@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var tilemap: TileMapLayer = %TileMapLayer

var _last_cell_index: int = 0
var _center_index: int = 0
var _is_odd: bool = false

@export_range(2, 10, 1) var width_cells: int = 2:
	set (value):
		width_cells = value
		update_dimenstions()


func get_atlas_coords(_index: int) -> Vector2i:
	var atlas_x: int = 2
	var atlas_y: int = 1
	
	if _index == 0:
		atlas_x = 2
	elif _index == _last_cell_index:
		atlas_x = 6
	elif _index == _center_index and _is_odd:
		atlas_x = 4
	else:
		atlas_x = 3
	return Vector2i(atlas_x, atlas_y)


func update_dimenstions():
	tilemap = get_node_or_null('%TileMapLayer')
	if tilemap == null:
		return
	collision_shape = %CollisionShape2D
	var cell_size_px: int = tilemap.tile_set.tile_size.x
	_last_cell_index = width_cells - 1
	_is_odd = width_cells % 2 == 1
	if _is_odd:
		_center_index = width_cells / 2
		
	
	tilemap.clear()
	for x in range(width_cells):
		tilemap.set_cell(
			Vector2i(x, 0), # coords
			0, # source id
			get_atlas_coords(x)  # atlas_coords
		)
	collision_shape.shape = RectangleShape2D.new()
	collision_shape.shape['size'] = Vector2(cell_size_px * width_cells, cell_size_px)
	%StaticBody2D.position.x = cell_size_px * width_cells / 2

func _ready() -> void:
	update_dimenstions()
	
