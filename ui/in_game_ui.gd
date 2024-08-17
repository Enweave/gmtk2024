extends CanvasLayer

class_name InGameUi
var health_component: HealthComponent
var block_amount: int = 0

func warn_block_full() -> void:
	%BlockAnimationPlayer.play("warn")

func update_ui() -> void:
	%StatusText.text = ""
	%HealthValue.text = str(health_component.current_health)
	if health_component.is_dead:
		%HealthValue.text = "0"
		%HealthValue.modulate = Color(1, 0, 0)
		%StatusText.text = "You died!"
	else:
		%HealthValue.modulate = Color(1, 1, 1)
		
	%BlockValue.text = str(block_amount)
	

func assign_health_component(_health_component: HealthComponent) -> void:
	health_component = _health_component
	health_component.OnDamage.connect(update_ui)
	health_component.OnDeath.connect(update_ui)
	health_component.OnHeal.connect(update_ui)
	update_ui()
	
