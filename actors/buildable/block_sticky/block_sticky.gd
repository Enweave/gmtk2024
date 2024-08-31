class_name BlockSticky
extends BlockBase

var raycast_length: float = 22

var stick_force: float = 1000
var connection_duration: float = 0.15
var gravity_timeout: float = 0.2


func _ready() -> void:
	super._ready()
	block_type = BlockType.STICKY
	self.gravity_scale = 0
	# Create the 4 raycasts left, top, right, bottom
	for i in range(4):
		var raycast := RayCast2D.new()
		raycast.enabled = false
		raycast.enabled = true
		raycast.exclude_parent = true
		raycast.add_exception(self)

		match i:
			0:
				raycast.target_position = Vector2(-raycast_length, 0)
			1:
				raycast.target_position = Vector2(0, -raycast_length)
			2:
				raycast.target_position = Vector2(raycast_length, 0)
			3:
				raycast.target_position = Vector2(0, raycast_length)

		raycast.ready.connect(do_sticky_thing.bind(raycast))
		self.add_child.call_deferred(raycast)
	
	await get_tree().create_timer(gravity_timeout).timeout
	self.gravity_scale = 1

func do_sticky_thing(ray_cast2d: RayCast2D) -> void:
	ray_cast2d.force_raycast_update()
	if ray_cast2d.is_colliding():
		var body: Node = ray_cast2d.get_collider()
		if body is TileMap:
			var collision_point: Vector2 = ray_cast2d.get_collision_point()
			# apply force towards the collision point
			var direction: Vector2 = (collision_point - global_position).normalized()
			self.apply_central_force(direction * stick_force)
			await get_tree().create_timer(connection_duration).timeout
			self.freeze = true


func _init() -> void:
	prefab = preload("res://actors/buildable/block_sticky/block_sticky.tscn")
	UI_Texture_path = "res://assets/spritesheets/props/block_sticky_icon.png"
