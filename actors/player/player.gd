extends CharacterBody2D
class_name Player

signal death

var scene_root

# state
var player_state : PlayerState

# cursor grid
var cursor_scene: PackedScene = preload("res://actors/player/grid_cursor.tscn")
var grid_cursor: GridCursor
var cursor_grid_size: int = 16
var use_cursor_grid: bool = true

# health
@export var max_health: float = 10

var health_component: HealthComponent
# weapon
var space_state: PhysicsDirectSpaceState2D
var inventory : Inventory

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
@export var WALL_JUMP_FORCE_X: float = 325.
@export var WALL_JUMP_FORCE_Y: float = 400.
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

# sound 
@onready var footsteps_timer: Timer = %FootstepsTimer
@onready var footsteps_sfx_player: RandomSFXPlayer = %FootstepsSFXPlayer
@onready var JumpSfxPlayer: RandomSFXPlayer = %JumpSfxPlayer


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
	player_state = GlobalPlayerState as PlayerState
	scene_root = get_parent()
	inventory = Inventory.new(player_state)
	health_component = HealthComponent.new(max_health)
	setup_ui()
	space_state = get_world_2d().direct_space_state
	health_component.OnDeath.connect(_on_death)
	footsteps_timer.connect("timeout", _on_footsteps_timer_timeout)
	if use_cursor_grid:
		grid_cursor = cursor_scene.instantiate()
		grid_cursor.rebuild_rectangle(cursor_grid_size)
		scene_root.add_child.call_deferred(grid_cursor)
		

func _on_death():
	death.emit()

var push_force: int = 2

func process_inventory(_delta):
	if Input.is_action_just_pressed("switch_slot_1"):
		inventory.switch_slot(BlockBase.BlockType.SIMPLE)
	elif Input.is_action_just_pressed("switch_slot_2"):
		inventory.switch_slot(BlockBase.BlockType.FROZEN)
	elif Input.is_action_just_pressed("switch_slot_3"):
		inventory.switch_slot(BlockBase.BlockType.MAGNET)

func _physics_process(delta):
	process_gravity(delta)
	player_run(delta)
	player_jump(delta)
	process_mouse(delta)
	move_and_slide()
	update_animations()
	process_inventory(delta)

	# push rigid bodies
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)


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


func process_mouse(_delta):
	var mouse_position: Vector2 = get_global_mouse_position()
	var mouse_position_grid_snapped: Vector2 = Vector2.ZERO
	
	if use_cursor_grid:
		mouse_position_grid_snapped = grid_cursor.snap_to_grid(mouse_position)
		
	if Input.is_action_just_pressed("fire"):
		beam.global_position = weapon_hotspot.global_position
		var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		var _beam_vector: Vector2 = mouse_position - beam.global_position
		var _distance = min(weapon_range, _beam_vector.length())

		params.position = beam.global_position + _beam_vector.normalized() * _distance
		beam.global_rotation = _beam_vector.angle() - PI/2
		
		var _beam_target: Node2D = beam.fire(_distance, weapon_cooldown)

		var results: Array[Dictionary] = space_state.intersect_point(params)
		if results.size() == 0 and !_beam_target:
			if inventory.selected_slot.can_remove_block(1):
				var block_instance := inventory.selected_slot.block.prefab.instantiate()
				if use_cursor_grid:
					block_instance.global_position = mouse_position_grid_snapped
				else:
					block_instance.global_position = params.position
				scene_root.add_child(block_instance)
				inventory.selected_slot.remove_block(1)
				beam.can_print = true
		else:
			for result in results:
				var collider = result["collider"]
				if collider is BlockBase:
					var _collider_block: BlockBase = collider
					if _beam_target != collider:
						return
					if inventory.get_slot(_collider_block.block_type).can_add_block(1):
						var _remove_result: int = collider.remove()
						inventory.get_slot(_collider_block.block_type).add_block(_remove_result)
						beam.can_print = bool(_remove_result)
					else:
						in_game_ui.warn_block_full()
		in_game_ui.update_ui()


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
