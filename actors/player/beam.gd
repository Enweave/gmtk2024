extends RayCast2D
class_name Beam

var scene_root
var inventory: Inventory
# state stuff
enum ShootResult {
	PICKUP,
	PRINT,
	FAIL
}
var _is_firing: bool = false
var _last_target: Vector2 = Vector2.ZERO

# visuals
@onready var beam_graphic: Line2D = %Line2D

var ray_time: float = 0.02
var _ray_time_accumulator: float = 0.0
var beam_color: Color = Color(0, 0, 255)
var beam_error_color: Color = Color(255, 0, 0)

# sound
@onready var gun_sfx_player: RandomSFXPlayer = %GunSfxPlayer
@onready var PrintPickupSfxPlayer: RandomSFXPlayer = %PrintPickupSfxPlayer
@onready var PrintSuccessSfxPlayer: RandomSFXPlayer = %PrintSuccessSfxPlayer
@onready var PrintFailSfxPlayer: RandomSFXPlayer = %PrintFailSfxPlayer


func _physics_process(delta: float) -> void:
	if _is_firing:
		_ray_time_accumulator += delta
		if _ray_time_accumulator >= ray_time:
			beam_graphic.points[1] = _last_target - self.global_position + Vector2(
				randf_range(-5, 5),
				randf_range(-5, 5)
			)
			_ray_time_accumulator = 0.0


func _enqueue_cooldown(_timeout: float) -> void:
	beam_graphic.points[1] = _last_target - self.global_position
	_is_firing = true
	beam_graphic.visible = true

	await get_tree().create_timer(_timeout).timeout

	_is_firing = false
	beam_graphic.visible = false


func _pickup_block(_block: BlockBase) -> void:
	if inventory.get_slot(_block.block_type).can_add_block() and !_block.is_being_removed:
		inventory.get_slot(_block.block_type).add_block()
		_block.pickup()
		_result_sfx(ShootResult.PICKUP)
		return
	_result_sfx(ShootResult.FAIL)


func _print_block(_target: Vector2) -> void:
	if inventory.selected_slot.can_remove_block():
		var block_instance := inventory.selected_slot.block.prefab.instantiate()
		block_instance.global_position = _target
		scene_root.add_child(block_instance)
		inventory.selected_slot.remove_block()
		_result_sfx(ShootResult.PRINT)
		return
	_result_sfx(ShootResult.FAIL)


func _result_sfx(_result: ShootResult):
	beam_graphic.default_color = beam_color
	match _result:
		ShootResult.PICKUP:
			PrintPickupSfxPlayer.play_random_sound()
		ShootResult.PRINT:
			PrintSuccessSfxPlayer.play_random_sound()
		ShootResult.FAIL:
			beam_graphic.default_color = beam_error_color
			PrintFailSfxPlayer.play_random_sound()


func shoot(_target: Vector2, _cooldown: float, _target_unoccupied: bool, _target_in_range: bool, _target_grid_snapped: Vector2, _use_grid: bool = false) -> void:
	if _is_firing:
		return
	gun_sfx_player.play_random_sound()

	_last_target = _target
	self.target_position = _last_target - self.global_position
	self.enabled = true
	self.force_raycast_update()
	var result_collider = null

	_enqueue_cooldown(_cooldown)

	if self.is_colliding():
		result_collider = self.get_collider()
		_last_target= self.get_collision_point()
		if result_collider is BlockBase:
			var _collider_block: BlockBase = result_collider
			_pickup_block(_collider_block)
			return
		else:
			_result_sfx(ShootResult.FAIL)
			return

	if _target_unoccupied and _target_in_range:
		if _use_grid:
			_last_target = _target_grid_snapped
		_print_block( _last_target)
		return

	_result_sfx(ShootResult.FAIL)
