extends Node2D

@export var damage_per_second: float = 1
@export var push_velocity: float = 500
@export var damage: float = 2

var targets: Array = []
var damage_time_step: float = 0.2
var damage_time_accumulator: float = 0


func damage_targets() -> void:
	for target in targets:
		if target is Player and HealthComponent.FIELD_NAME in target:
			target.damaged(damage)
		elif HealthComponent.FIELD_NAME in target:
			var health_component: HealthComponent = target[HealthComponent.FIELD_NAME]
			health_component.damage(damage)
		

func _process(delta: float) -> void:
	pass
	#if targets.size() > 0:
		#damage_time_accumulator += delta
		#if damage_time_accumulator >= damage_time_step:
			#damage_time_accumulator = 0
			#damage_targets(damage_time_step)


func _on_push_area_2d_2_body_entered( body: Node ) -> void:
	if body is CharacterBody2D:
		var _character_body: CharacterBody2D = body
		_character_body.velocity.y = -push_velocity


func _on_area_2d_body_entered( body: Node ) -> void:
	if HealthComponent.FIELD_NAME in body:
		targets.append(body)
		damage_targets()
		#var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
		#health_component.damage(damage_per_second*damage_time_step)


func _on_area_2d_body_exited( body: Node ) -> void:
	if HealthComponent.FIELD_NAME in body:
		targets.erase(body)
