extends CanvasLayer

class_name InGameUi
var health_component: HealthComponent
var inventory: Inventory
var slots: Array
@onready var death_sfx_player : AudioStreamPlayer = %DeathPlayer

func warn_block_full() -> void:
	%BlockAnimationPlayer.play("warn")

func update_ui() -> void:
	%StatusText.text = ""
	%HealthValue.text = "%.1f" % health_component.current_health
	if health_component.is_dead:
		%HealthValue.text = "0"
		%HealthValue.modulate = Color(1, 0, 0)
		%StatusText.text = "You died!"
	else:
		%HealthValue.modulate = Color(1, 1, 1)
		
	for slot in slots:
		var _slot: SlotWidget = slot
		_slot.set_quantity(slot.inventory_slot.current_blocks, slot.inventory_slot.MAX_BLOCKS)
		if _slot.inventory_slot.is_selected:
			_slot.modulate = Color(1, 1, 1)
		else:
			_slot.modulate = Color(0.5, 0.5, 0.5)

func _on_damage(_amount: float) -> void:
	update_ui()
	
func _on_heal(_amount: float) -> void:
	update_ui()
		
func _on_death():
	death_sfx_player.play()
	print("Player died")
	update_ui()

func assign_health_component(_health_component: HealthComponent) -> void:
	health_component = _health_component
	health_component.OnDamage.connect(_on_damage)
	health_component.OnDeath.connect(_on_death)
	health_component.OnHeal.connect(_on_heal)
	
	
func assign_inventory(_inventory: Inventory) -> void:
	inventory = _inventory
	for slot in inventory.slots_map.values():
		slot.quantity_changed.connect(update_ui)
	inventory.slot_switched.connect(update_ui)
	inventory.blocks_full.connect(warn_block_full)

	var _slots : HBoxContainer = %Slots
	slots = []
	for child in _slots.get_children():
		child.queue_free()
		
	for slot in inventory.slots_map.values():
		var slot_ui:= preload("res://ui/slot_widget.tscn").instantiate()
		_slots.add_child(slot_ui)
		slot_ui.set_texture(slot.get_texture())
		slot_ui.inventory_slot = slot
		slots.append(slot_ui)
