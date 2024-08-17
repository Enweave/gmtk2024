extends CanvasLayer

class_name InGameUi
var health_component: HealthComponent

func _update_ui() -> void:
	%StatusText.text = ""
	%HealthValue.text = str(health_component.current_health)
	if health_component.is_dead:
		%HealthValue.text = "0"
		%HealthValue.modulate = Color(1, 0, 0)
		%StatusText.text = "You died!"
	else:
		%HealthValue.modulate = Color(1, 1, 1)
	

func assign_health_component(_health_component: HealthComponent) -> void:
	health_component = _health_component
	health_component.OnDamage.connect(_update_ui)
	health_component.OnDeath.connect(_update_ui)
	health_component.OnHeal.connect(_update_ui)
	_update_ui()
	
