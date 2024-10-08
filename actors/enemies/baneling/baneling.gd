@tool
extends CharacterBody2D
class_name Baneling
const SPEED: float = 300.0
const PATROL_SPEED: float = 100.0
const patrol_time: float = 1.0
@export var enable_patrol: bool = true

@export_range(50, 1000, 1) var vision_radius: float = 200:
	set (value):
		vision_radius = value
		update_params()

@export_range(15, 1000, 1) var trigger_radius: float = 24:
	set (value):
		trigger_radius = value
		update_params()

@export var explosion_force: float = 100
@export var explosion_radius: float = 54
@export var max_health: float = 3
@export var damage: float = 3
@export var explosion_scene: PackedScene = preload("res://actors/enemies/fx/explosion.tscn")

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var vision_area: Area2D = %vision
@onready var vision_trigger: Area2D = %trigger

var health_component: HealthComponent
var player: Player = null
var current_speed: float = PATROL_SPEED
var patrol_idle: bool = true
var last_patrol_direction: int = 1
var footsteps_timestep: float = 0.3
var friction: float = 3
var explosion_triggered: bool = false

@onready var FootstepsPlayer: RandomSFXPlayer = %FootstepsPlayer
@onready var FootstepsTimer: Timer = %FootstepsTimer


func update_params():
	%VisionCollisionShape2D.shape = CircleShape2D.new()
	%VisionCollisionShape2D.shape.radius = vision_radius
	%TriggerCollisionShape2D.shape = CircleShape2D.new()
	%TriggerCollisionShape2D.shape.radius = trigger_radius


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	update_params()

	health_component = HealthComponent.new(max_health)
	current_speed = PATROL_SPEED

	if enable_patrol:
		var timer = Timer.new()
		timer.set_one_shot(false)
		timer.set_wait_time(patrol_time)
		timer.connect("timeout", _on_patrol_timeout)
		self.add_child(timer)
		timer.start()

	health_component.OnDeath.connect(explode)

	FootstepsTimer.connect("timeout", _on_footsteps_timer_timeout)
	footsteps_timestep = FootstepsTimer.get_wait_time()


func _on_footsteps_timer_timeout():
	if velocity.x != 0 and is_on_floor():
		FootstepsPlayer.play_random_sound()


func _on_patrol_timeout() -> void:
	if player:
		return
	if patrol_idle:
		patrol_idle = false
		velocity.x = current_speed * last_patrol_direction
	else:
		patrol_idle = true
		velocity.x = 0
		last_patrol_direction *= -1


func _on_vision_area_body_entered(body: Node) -> void:
	if body is Player:
		player = body as Player


func _on_vision_area_body_exited(body: Node) -> void:
	if body is Player:
		player = null


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if !health_component.is_dead:
		if player:
			current_speed = SPEED
			velocity.x = move_toward(velocity.x, current_speed * sign(player.global_position.x - global_position.x), friction)
			var speed_scale = abs(velocity.x)/PATROL_SPEED
			animated_sprite.speed_scale = speed_scale
			FootstepsTimer.set_wait_time(clamp(footsteps_timestep/speed_scale, 0.1, footsteps_timestep))
		else:
			animated_sprite.speed_scale = 1
			current_speed = PATROL_SPEED
			FootstepsTimer.set_wait_time(footsteps_timestep)
			if !enable_patrol:
				velocity.x = move_toward(velocity.x, 0, friction)

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	update_animations()


func explode():
	if explosion_triggered:
		return
	explosion_triggered = true
	for target in vision_area.get_overlapping_bodies():
		if (self.global_position - target.global_position).length() < explosion_radius and target != self:
			if target is RigidBody2D:
				var _target: RigidBody2D = target as RigidBody2D
				_target.apply_central_impulse((target.global_position - self.global_position).normalized() * explosion_force)
			if HealthComponent.FIELD_NAME in target:
				var _health_component: HealthComponent = target[HealthComponent.FIELD_NAME]
				_health_component.damage(damage)

	var explosion := explosion_scene.instantiate()
	explosion.global_position = global_position
	self.get_parent().add_child(explosion)
	self.queue_free()


func _on_trigger_body_entered(body: Node) -> void:
	if body is Player and !health_component.is_dead:
		player = body as Player
		health_component.instakill()


func update_animations():
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x > 0
	else:
		animated_sprite.play("idle")
