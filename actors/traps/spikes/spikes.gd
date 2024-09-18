extends Node2D

@export var damage_per_second: float = 1
@export var push_velocity: float = 500
@export var damage: float = 2


func _on_push_area_2d_2_body_entered( body: Node ) -> void:
	if body is CharacterBody2D:
		var _character_body: CharacterBody2D = body
		if _character_body.transform.origin.y < transform.origin.y:
			_character_body.velocity.y = -push_velocity
		else:
			_character_body.velocity.y = push_velocity


func _on_area_2d_body_entered( body: Node ) -> void:
	var _health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
	_health_component.damage(damage)
