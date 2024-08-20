extends CharacterBody2D

class_name Baneling
const SPEED: float = 300.0
const PATROL_SPEED: float = 100.0
const patrol_time: float = 1.0

@export var max_health: float = 3
@export var damage: float = 3

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var vision_area: Area2D = %vision
@onready var vision_trigger: Area2D = %trigger

var health_component: HealthComponent

var player: Player = null
var current_speed: float = PATROL_SPEED
var patrol_idle: bool = true
var last_patrol_direction: int = 1

func _ready() -> void:
	health_component = HealthComponent.new(max_health)
	var timer = Timer.new()
	timer.set_one_shot(false)
	timer.set_wait_time(patrol_time)

	timer.connect("timeout", _on_patrol_timeout)
	current_speed = PATROL_SPEED
	self.add_child(timer)
	timer.start()

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
	if !health_component.is_dead:
		if player:
			current_speed = SPEED
			velocity.x = move_toward(velocity.x, current_speed * sign(player.global_position.x - global_position.x), SPEED/100)
		else:
			current_speed = PATROL_SPEED
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	move_and_slide()
	update_animations()

	
func _on_trigger_body_entered(body: Node) -> void:
	if body is Player and !health_component.is_dead:
		player = body as Player
		player.health_component.damage(damage)
		health_component.instakill()
		self.queue_free()

func update_animations():
	if velocity.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = velocity.x > 0
	else:
		animated_sprite.play("idle")
