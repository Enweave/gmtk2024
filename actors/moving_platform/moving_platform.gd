@tool
extends AnimatableBody2D

## how fast the platform moves along the path
@export var path_time: float = 0.5
## the path the platform will follow
@export var path2d: Path2D
## how long the platform will rest at the end of the path
@export var rest_time: float = 0.1
## if true, the platform will move back and forth along the path
@export var back_and_forth: bool = true
## how long the platform will wait before starting
@export var delay: float = 0

## the size of the grid
var grid_size: int = 16
var _follower: Node2D
var _direction: int = 1
var _progress: float = 0.
var _time_elapsed: float = 0
var _timer: Timer
var _tick_time: float = 0.01

@export_range(1, 10, 1) var width_cells: int:
	set (value):
		width_cells = value
		print(width_cells)
		update_dimenstions()

@export_range(1, 10, 1) var height_cells: int:
	set (value):
		height_cells = value
		update_dimenstions()

var path_follow: PathFollow2D


func update_dimenstions():
	var _width_pixels: int = width_cells * grid_size
	var _height_pixels: int = height_cells * grid_size
	
	%CollisionShape2D.shape = RectangleShape2D.new()
	%CollisionShape2D.shape['size']= Vector2(_width_pixels, _height_pixels)
	%Polygon2D.polygon = [
		Vector2(-_width_pixels/2, -_height_pixels/2),
		Vector2(_width_pixels/2, -_height_pixels/2),
		Vector2(_width_pixels/2, _height_pixels/2),
		Vector2(-_width_pixels/2, _height_pixels/2),
	]
	
	%Polygon2D.uv = [
		Vector2(0, 0),
		Vector2(_width_pixels, 0),
		Vector2(_width_pixels, _height_pixels),
		Vector2(0, _height_pixels),
	]


func _on_destination_reached():
	_timer.stop()
	_time_elapsed = 0
	if back_and_forth:
		_direction = -_direction
	if rest_time > 0:
		await get_tree().create_timer(rest_time).timeout
	_timer.start()


func _tick():
	_time_elapsed += _tick_time
	if _direction == 1:
		_progress = _time_elapsed / path_time
	else:
		_progress = 1 - _time_elapsed / path_time
	path_follow.progress_ratio = clampf(_progress, 0, 1)

	# because of this bug https://github.com/godotengine/godot/issues/63140
	# AnimatableBody2d parented to PathFollow2D doesn't update colliion
	# the workaround is to update the global position manually from dummy (_follower) node
	self.global_position = _follower.global_position

	if _time_elapsed >= path_time:
		_on_destination_reached()


func start_motion():
	_timer = Timer.new()
	_timer.set_wait_time(_tick_time)
	_timer.set_one_shot(false)
	_timer.autostart = true
	_timer.timeout.connect(_tick)
	self.add_child.call_deferred(_timer)


func _on_path_follow_ready() -> void:
	path_follow.add_child(_follower)
	start_motion()


func _ready():
	update_dimenstions()
	_follower = Node2D.new()
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	if path2d and not Engine.is_editor_hint():
		path_follow = PathFollow2D.new()
		path_follow.rotates = false
		path_follow.ready.connect(_on_path_follow_ready)
		path2d.add_child.call_deferred(path_follow)
