extends CharacterBody2D

class_name Player

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = %AnimatedSprite

@export var SPEED: float = 200.
@export var JUMP_FORCE: float = 300.
@export var NUM_JUMPS: int = 2
@export var block_scene: PackedScene = preload("res://actors/buildable/block/block.tscn")

var space_state: PhysicsDirectSpaceState2D
var jumps_left: int = NUM_JUMPS
var just_jumped: bool = false
var FRICTION: float = SPEED/10

enum PlayerState {
	IDLE,
	RUN,
	JUMP,
	FALL
}

var StateAnimationMap: Dictionary = {
	PlayerState.IDLE: "idle",
	PlayerState.RUN: "run",
	PlayerState.JUMP: "jump",
	PlayerState.FALL: "fall"
}

var current_state: PlayerState = PlayerState.IDLE

func _ready():
	space_state = get_world_2d().direct_space_state

func _physics_process(delta):
	process_gravity(delta) 
	player_run(delta)
	player_jump(delta)
	process_mouse(delta)
	move_and_slide()
	update_animations()

func player_jump(_delta):
	if jumps_left > 0:
		if Input.is_action_just_pressed("jump"):
			just_jumped = true
			velocity.y = -JUMP_FORCE
			jumps_left -= 1
			current_state = PlayerState.JUMP


func process_mouse(_delta):
	if Input.is_action_just_pressed("fire"):
		# get the mouse position
		var mouse_position: Vector2 = get_global_mouse_position()
		var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		params.position = mouse_position
		var results: Array[Dictionary] = space_state.intersect_point(params)
		# check if space is free around the mouse position
		if results.size() == 0:
			# create a new block at the mouse position
			var block_instance : Block = block_scene.instantiate()
			block_instance.position = mouse_position
			get_tree().get_root().add_child(block_instance)
		else:
			# remove the block at the mouse position
			for result in results:
				var collider = result["collider"]
				if collider is Block:
					collider.remove()
		
		
func process_gravity(delta):
	if is_on_floor():
		jumps_left = NUM_JUMPS
		just_jumped = false
		current_state = PlayerState.IDLE
	else:
		if !just_jumped:
			just_jumped = true
			jumps_left -= 1
		if velocity.y > 0:
			current_state = PlayerState.FALL
		velocity.y += gravity * delta

func player_run(_delta):
	var direction: float = Input.get_axis("move_left", "move_right")

	if direction != 0:
		current_state = PlayerState.RUN
		velocity.x = move_toward(velocity.x, direction * SPEED, FRICTION)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)


func update_animations():
	animated_sprite.play(StateAnimationMap[current_state])
