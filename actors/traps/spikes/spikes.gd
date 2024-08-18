extends Node2D

@export var damage_per_second: float = 1
var targets : Array = []
var damage_time_step: float = 0.2
var damage_time_accumulator: float = 0

func damage_targets(delta: float) -> void:
	for target in targets:
		if HealthComponent.FIELD_NAME in target:
			var health_component: HealthComponent = target[HealthComponent.FIELD_NAME]
			health_component.damage(damage_per_second * delta)

func _process(delta: float) -> void:
	if targets.size() > 0:
		damage_time_accumulator += delta
		if damage_time_accumulator >= damage_time_step:
			damage_time_accumulator = 0
			damage_targets(damage_time_step)

func _on_area_2d_body_entered( body: Node ) -> void:
	if HealthComponent.FIELD_NAME in body:
		targets.append(body)

func _on_area_2d_body_exited( body: Node ) -> void:
	if HealthComponent.FIELD_NAME in body:
		targets.erase(body)