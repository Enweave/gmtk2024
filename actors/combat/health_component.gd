extends RefCounted
class_name HealthComponent
const FIELD_NAME: String = "health_component"
signal OnDamage(amount: float)
signal OnHeal(amount: float)
signal OnDeath
var _max_health: float = 10.
var current_health: float
var is_invulnerable: bool = false
var is_dead: bool = false


func _init(max_health: float) -> void:
	_max_health = max_health
	current_health = _max_health


func update_max_health(value: float) -> void:
	_max_health = value
	current_health = min(current_health, _max_health)


func damage(amount: float) -> void:
	if is_invulnerable:
		return
	current_health -= amount #amount

	if current_health <= 0:
		is_dead = true
		OnDeath.emit()
	OnDamage.emit(amount)


func instakill() -> void:
	is_dead = true
	current_health = 0
	OnDeath.emit()


func is_full() -> bool:
	return current_health == _max_health


func heal(amount: float) -> void:
	current_health = min(current_health + amount, _max_health)
	OnHeal.emit(amount)
	
