extends CharacterBody2D
class_name Player

# health
@export var max_health: float = 10
var health_component: HealthComponent

# weapon
var space_state: PhysicsDirectSpaceState2D
@export var block_scene: PackedScene = preload("res://actors/buildable/block/block.tscn")

# movement
@export var SPEED: float = 200.
var FRICTION: float = SPEED/10

# jump and gravity
@export var JUMP_FORCE: float = 300.
@export var NUM_JUMPS_MAX: int = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_num_jumps_max: int = NUM_JUMPS_MAX
var jumps_left: int = NUM_JUMPS_MAX
var jump_queued: bool = false
var jump_buffer: float = 0.1
var coyote_time: float = 0.2
var coyote_triggered: bool = false

# animation
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
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

func _ready():
	health_component = HealthComponent.new(max_health)
	setup_ui()
	space_state = get_world_2d().direct_space_state


var push_force: int = 2
func _physics_process(delta):
	process_gravity(delta)
	player_run(delta)
	player_jump(delta)
	process_mouse(delta)
	move_and_slide()
	update_animations()
	
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


func player_jump(_delta):
	if Input.is_action_just_pressed("jump"):
		if jumps_left > 0:
			_player_jump()
		else:
			jump_queued = true
			await get_tree().create_timer(jump_buffer).timeout
			if jump_queued and jumps_left > 0:
				_player_jump()
			jump_queued = false


func process_mouse(_delta):
	if Input.is_action_just_pressed("fire"):
		var mouse_position: Vector2 = get_global_mouse_position()
		var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		params.position = mouse_position
		var results: Array[Dictionary] = space_state.intersect_point(params)
		if results.size() == 0:
			var block_instance: Block = block_scene.instantiate()
			block_instance.position = mouse_position
			get_tree().get_root().add_child(block_instance)
		else:
			for result in results:
				var collider = result["collider"]
				if collider is Block:
					collider.remove()


func coyote():
	if not coyote_triggered:
		coyote_triggered = true
		await get_tree().create_timer(coyote_time).timeout
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
			_player_jump()
	else:
		coyote()
		if velocity.y > 0:
			current_state = PlayerAnimationState.FALL
		velocity.y += gravity * delta


func player_run(_delta):
	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0:
		current_state = PlayerAnimationState.RUN
		velocity.x = move_toward(velocity.x, direction * SPEED, FRICTION)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)


func update_animations():
	if animated_sprite.animation != StateAnimationMap[current_state]:
		animated_sprite.play(StateAnimationMap[current_state])
