extends RayCast2D

class_name Beam

@onready var beam: Line2D = %Line2D
@export var beam_color: Color = Color(0, 0, 255)
@export var beam_error_color : Color = Color(255, 0, 0)
var is_firing : bool = false
var ray_time: float = 0.02
var ray_time_accumulator: float = 0.0
var beam_target: Vector2 = Vector2.ZERO
var can_print: bool = false
var result_played: bool = false
var result_collider: Node2D = null
@onready var gun_sfx_player : RandomSFXPlayer = %GunSfxPlayer
@onready var PrintPickupSfxPlayer : RandomSFXPlayer = %PrintPickupSfxPlayer
@onready var PrintSuccessSfxPlayer : RandomSFXPlayer = %PrintSuccessSfxPlayer
@onready var PrintFailSfxPlayer : RandomSFXPlayer = %PrintFailSfxPlayer

func play_result():
	if result_played:
		return
	result_played = true
	if result_collider and can_print:
		PrintSuccessSfxPlayer.play_random_sound()
	elif not result_collider and can_print:
		PrintPickupSfxPlayer.play_random_sound()
	elif not can_print:
		PrintFailSfxPlayer.play_random_sound()


func _physics_process(delta: float) -> void:
	if is_firing:
		if can_print:
			beam.default_color = beam_color
		else:
			beam.default_color = beam_error_color
		ray_time_accumulator += delta
		if ray_time_accumulator >= ray_time:
			beam.points[1] = beam_target + Vector2(
				randf_range(-5, 5),
				randf_range(-5, 5)
			)
			ray_time_accumulator = 0.0
			play_result()

func _fire(_timeout: float = 0.5) -> void:
	await get_tree().create_timer(_timeout).timeout
	is_firing = false
	beam.visible = false
	can_print = false
	
func fire(max_distance: float, beam_cooldown) -> Node2D:
	if is_firing:
		return null
	result_played = false
	is_firing = true
	beam.visible = true
	self.target_position.y = max_distance
	self.enabled = true
	self.force_raycast_update()

	
	result_collider = null
	if self.is_colliding():
		result_collider = self.get_collider()
		beam_target = Vector2(0, (self.get_collision_point()- beam.global_position).length())
	else:
		beam_target = self.target_position
	
	self.enabled = false
	_fire(beam_cooldown)
	gun_sfx_player.play_random_sound()
	
	return result_collider
