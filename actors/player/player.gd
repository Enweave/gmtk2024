extends CharacterBody2D
class_name Player

signal death
var scene_root
# state
var player_state: PlayerState
# cursor
var is_aiming: bool = false
var crosshair: Crosshair
var crosshair_scene: PackedScene = preload("res://actors/player/crosshair.tscn")
var crosshair_position: Vector2 = Vector2.ZERO
var grid_cursor_scene: PackedScene = preload("res://actors/player/grid_cursor.tscn")
var grid_cursor: GridCursor
var cursor_grid_size: int = 16
var use_cursor_grid: bool = false
var gamepad_crosshair_speed: float = 250
var gamepad_crosshair_momentum: float = 0
var gamepad_crosshair_momentum_delta: float = 0.7
var gamepad_crosshair_range_x: float = 440
var gamepad_crosshair_range_y: float = 255
var gamepad_crosshair_offset: Vector2 = Vector2.ZERO

# camera stuff
@onready var player_camera: Camera2D = %Camera2D

var camera_interpolation: float = 8.
var max_camera_offset_x: int = 220
var max_camera_offset_y: int = 140

# health
@export var max_health: float = 10

var health_component: HealthComponent
# weapon
var target_params: PhysicsPointQueryParameters2D
var space_state: PhysicsDirectSpaceState2D
var inventory: Inventory

@export var weapon_range: float = 400
@export var weapon_cooldown: float = 0.2

@onready var weapon_pivot: Node2D = %WeaponPivot
@onready var weapon_hotspot: Node2D = %WeaponHotSpot
@onready var beam: Beam = %Beam
@onready var wall_cast: RayCast2D = %WallCaster

# movement
@export var SPEED: float = 200.

var FRICTION: float = SPEED/10

# jump and gravity
@export var JUMP_FORCE: float = 300.
@export var WALL_JUMP_FORCE_X: float = 335.
@export var WALL_JUMP_FORCE_Y: float = 275.
@export var NUM_JUMPS_MAX: int = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_num_jumps_max: int = NUM_JUMPS_MAX
var jumps_left: int = NUM_JUMPS_MAX
var jump_queued: bool = false
var jump_buffer: float = 0.1
var coyote_time: float = 0.15
var coyote_triggered: bool = false
var is_on_wall_recently: bool = false

# animation
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var JumpSprite: AnimatedSprite2D = %JumpSprite

var in_game_ui: InGameUi
enum PlayerAnimationState {
	IDLE,
	RUN,
	JUMP,
	FALL
}

var StateAnimationMap: Dictionary = {
	PlayerAnimationState.IDLE: "idle",
	PlayerAnimationState.RUN: "run",
	PlayerAnimationState.JUMP: "jump",
	PlayerAnimationState.FALL: "fall"
}

var current_state: PlayerAnimationState = PlayerAnimationState.IDLE

var _on_damage_is_playing: bool = false
var _on_damage_effect_time: float = 0.5
var _on_damage_effect_ammount: float = 5

# sound 
@onready var footsteps_timer: Timer = %FootstepsTimer
@onready var footsteps_sfx_player: RandomSFXPlayer = %FootstepsSFXPlayer
@onready var JumpSfxPlayer: RandomSFXPlayer = %JumpSfxPlayer
@onready var damage_sfx_player: RandomSFXPlayer = %DamageSfxPlayer

func _play_footsteps_sound():
	if is_on_floor():
		footsteps_sfx_player.play_random_sound()


func _on_footsteps_timer_timeout():
	_play_footsteps_sound()


func _toggle_footsteps_sound(_is_on: bool):
	if _is_on:
		if footsteps_timer.is_stopped():
			_play_footsteps_sound()
			footsteps_timer.start()
	else:
		if !footsteps_timer.is_stopped():
			footsteps_timer.stop()


func update_camera_bounds(left: int, top: int, right: int, bottom: int):
	%Camera2D.limit_left = left
	%Camera2D.limit_top = top
	%Camera2D.limit_right = right
	%Camera2D.limit_bottom = bottom


func setup_ui():
	var existing_ui: InGameUi
	var game_ui: Node = get_tree().get_root().get_node_or_null("/root/GameUI")
	if game_ui:
		existing_ui = game_ui.get_node_or_null("%InGameUI")

	if existing_ui:
		in_game_ui = existing_ui
		in_game_ui.show()
	else:
		in_game_ui = preload("res://ui/InGameUI.tscn").instantiate()
		get_tree().get_root().add_child.call_deferred(in_game_ui)
	in_game_ui.assign_health_component(health_component)
	in_game_ui.assign_inventory(inventory)
	in_game_ui.update_ui()


func _ready():
	scene_root = get_parent()
	crosshair = crosshair_scene.instantiate()
	crosshair.visible = false
	scene_root.add_child.call_deferred(crosshair)
	player_state = GlobalPlayerState as PlayerState
	player_state.asign_player(self)

	inventory = Inventory.new(player_state)
	health_component = HealthComponent.new(max_health)
	setup_ui()
	space_state = get_world_2d().direct_space_state
	health_component.OnDeath.connect(_on_death)
	footsteps_timer.connect("timeout", _on_footsteps_timer_timeout)

	beam.scene_root = scene_root
	beam.inventory = inventory
	target_params = PhysicsPointQueryParameters2D.new()

	health_component.OnDamage.connect(_on_damage)
	if use_cursor_grid:
		grid_cursor = grid_cursor_scene.instantiate()
		grid_cursor.rebuild_rectangle(cursor_grid_size)
		scene_root.add_child.call_deferred(grid_cursor)


func _on_damage(_amount: float):
	if !_on_damage_is_playing:
		_on_damage_is_playing = true
		damage_sfx_player.play_random_sound()
		await get_tree().create_timer(_on_damage_effect_time).timeout
		_on_damage_is_playing = false


func _on_death():
	death.emit()

var push_force: int = 2


func _physics_process(delta):
	process_gravity(delta)
	player_run(delta)
	player_jump(delta)
	calc_crosshair_position(delta)
	move_and_slide()
	update_animations()


# push rigid bodies
#for i in get_slide_collision_count():
#var c = get_slide_collision(i)
#if c.get_collider() is RigidBody2D:
#c.get_collider().apply_central_impulse(-c.get_normal() * push_force)


func _process(_delta):
	process_aim_and_fire(_delta)
	do_camera_offset(_delta)


func _player_jump():
	velocity.y = -JUMP_FORCE
	jumps_left -= 1
	current_state = PlayerAnimationState.JUMP
	jump_queued = false
	JumpSfxPlayer.play_random_sound()
	JumpSprite.stop()
	JumpSprite.play("fire")


func _player_walljump():
	velocity.y = -WALL_JUMP_FORCE_Y
	velocity.x = WALL_JUMP_FORCE_X * -wall_cast.scale.x
	current_state = PlayerAnimationState.JUMP
	is_on_wall_recently = false
	jump_queued = false
	JumpSfxPlayer.play_random_sound()
	JumpSprite.stop()
	JumpSprite.play("fire")


func player_jump(_delta):
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_recently and not is_on_floor():
			_player_walljump()
		elif jumps_left > 0:
			_player_jump()
		else:
			jump_queued = true
			await get_tree().create_timer(jump_buffer).timeout
			if jump_queued and jumps_left > 0:
				_player_jump()
			elif jump_queued and is_on_wall_recently:
				_player_walljump()
			jump_queued = false


func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_look"):
			is_aiming = true
		if event.is_action_released("mouse_look"):
			is_aiming = false
	if event is InputEventJoypadButton:
		if event.is_action_pressed("gamepad_aim_reset"):
			gamepad_crosshair_offset = Vector2.ZERO

	if event.is_action_pressed("switch_slot_1"):
		inventory.switch_slot(BlockBase.BlockType.SIMPLE)
	elif event.is_action_pressed("switch_slot_2"):
		inventory.switch_slot(BlockBase.BlockType.FROZEN)
	elif event.is_action_pressed("switch_slot_3"):
		inventory.switch_slot(BlockBase.BlockType.MAGNET)
	elif event.is_action_pressed("switch_slot_4"):
		inventory.switch_slot(BlockBase.BlockType.STICKY)
	elif event.is_action_pressed("next_slot"):
		inventory.next_slot()
	elif event.is_action_pressed("prev_slot"):
		inventory.previous_slot()


func calc_crosshair_position(_delta):
	if player_state.is_using_mouse_and_keyboard:
		crosshair_position = get_global_mouse_position()

	else:
		var direction: Vector2 = Vector2.ZERO
		direction.x = Input.get_action_strength("gamepad_aim_right") - Input.get_action_strength("gamepad_aim_left")
		direction.y = Input.get_action_strength("gamepad_aim_down") - Input.get_action_strength("gamepad_aim_up")
		if direction.length() > 0:
			gamepad_crosshair_momentum = clamp(gamepad_crosshair_momentum + gamepad_crosshair_momentum_delta * _delta, 0, 1)
			var _rate = gamepad_crosshair_speed * gamepad_crosshair_momentum * _delta
			gamepad_crosshair_offset.x = clamp(gamepad_crosshair_offset.x + direction.x * _rate, -gamepad_crosshair_range_x, gamepad_crosshair_range_x)
			gamepad_crosshair_offset.y = clamp(gamepad_crosshair_offset.y + direction.y * _rate, -gamepad_crosshair_range_y, gamepad_crosshair_range_y)
		else:
			gamepad_crosshair_momentum = clamp(gamepad_crosshair_momentum - gamepad_crosshair_momentum_delta * _delta, 0, 1)
		crosshair.set_valid(gamepad_crosshair_offset.length() < weapon_range)
		crosshair_position = weapon_pivot.global_position + gamepad_crosshair_offset

	crosshair.global_position = crosshair_position


func do_camera_offset(_delta: float):
	if is_aiming or !player_state.is_using_mouse_and_keyboard:
		var mid_point_x: float = self.global_position.x + (crosshair_position.x - self.global_position.x) / 2
		var mid_point_y: float = self.global_position.y + (crosshair_position.y - self.global_position.y) / 2
		var clamped_camera_x: float = clamp(mid_point_x, self.global_position.x - max_camera_offset_x, self.global_position.x + max_camera_offset_x)
		var clamped_camera_y: float = clamp(mid_point_y, self.global_position.y - max_camera_offset_y, self.global_position.y + max_camera_offset_y)
		player_camera.global_position = player_camera.global_position.lerp(Vector2(clamped_camera_x, clamped_camera_y), _delta*camera_interpolation)
	else:
		player_camera.global_position = player_camera.global_position.lerp(self.global_position, _delta*camera_interpolation)

	if _on_damage_is_playing:
		player_camera.global_position += Vector2(randf_range(-_on_damage_effect_ammount, _on_damage_effect_ammount), randf_range(-_on_damage_effect_ammount, _on_damage_effect_ammount))


func process_aim_and_fire(_delta):
	var target_position: Vector2 = Vector2.ZERO
	var target_position_grid_snapped: Vector2 = Vector2.ZERO

	var _beam_vector: Vector2 = crosshair_position - beam.global_position
	var distance: float

	var target_unoccupied: bool = true
	var target_in_range: bool = false
	var target_pickable: bool = false

	beam.global_position = weapon_hotspot.global_position

	if _beam_vector.length() <= weapon_range:
		target_in_range = true
		distance = _beam_vector.length()
	else:
		distance = weapon_range

	target_position = beam.global_position + _beam_vector.normalized() * distance
	target_params.position = target_position

	if use_cursor_grid:
		for i in space_state.intersect_point(target_params):
			target_unoccupied = false
			if i.collider is BlockBase:
				target_pickable = true
				break
		target_position_grid_snapped = grid_cursor.snap_to_grid(target_position, target_in_range, target_unoccupied, target_pickable)

	if Input.is_action_just_pressed("fire"):
		if !use_cursor_grid:
			target_unoccupied = space_state.intersect_point(target_params).size() == 0

		beam.shoot(target_position, weapon_cooldown, target_unoccupied, target_in_range, target_position_grid_snapped, use_cursor_grid)


func coyote():
	if not coyote_triggered:
		coyote_triggered = true
		await get_tree().create_timer(coyote_time).timeout
		is_on_wall_recently = false
		if not is_on_floor():
			current_num_jumps_max = NUM_JUMPS_MAX - 1
			jumps_left = min(jumps_left, current_num_jumps_max)
		coyote_triggered = false


func process_gravity(delta):
	if is_on_floor():
		coyote_triggered = false
		current_num_jumps_max = NUM_JUMPS_MAX
		jumps_left = current_num_jumps_max
		current_state = PlayerAnimationState.IDLE
		if jump_queued:
			_player_jump() #doesn't get run?
	elif is_on_wall_only():
		is_on_wall_recently = true
		if jump_queued:
			_player_walljump()
		else:
			if velocity.y >= 0:
				velocity.y = gravity * delta * 5
			else:
				velocity.y += gravity * delta
	else:
		coyote()
		if velocity.y > 0:
			current_state = PlayerAnimationState.FALL
		velocity.y += gravity * delta


func player_run(_delta):
	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0:
		if is_on_floor():
			current_state = PlayerAnimationState.RUN
		velocity.x = move_toward(velocity.x, direction * SPEED, FRICTION)
		animated_sprite.flip_h = direction < 0
		if direction < 0:
			weapon_pivot.rotation_degrees = 180.
			wall_cast.scale.x = -1
		else:
			weapon_pivot.rotation_degrees = 0
			wall_cast.scale.x = 1
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)


func update_animations():
	if animated_sprite.animation != StateAnimationMap[current_state]:
		animated_sprite.play(StateAnimationMap[current_state])

	if current_state == PlayerAnimationState.RUN:
		_toggle_footsteps_sound(true)
	else:
		_toggle_footsteps_sound(false)
