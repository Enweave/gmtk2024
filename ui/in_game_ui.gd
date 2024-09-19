extends CanvasLayer
class_name InGameUi
var health_component: HealthComponent
var inventory: Inventory
var slots: Array
# { CollectibleBase.CollectibleType: CollectibleWidget }
var collectible_widgets: Dictionary
const slot_widget_path: String = "res://ui/slot_widget.tscn"
const collectible_widget_path: String = "res://ui/collectible_widget.tscn"
@onready var death_sfx_player: AudioStreamPlayer = %DeathPlayer
@onready var collectible_sfx_player: AudioStreamPlayer = %CollectiblePlayer

func warn_block_full() -> void:
	%BlockAnimationPlayer.play("warn")


func _get_total_collectible_amount(_type: CollectibleBase.CollectibleType) -> int:
	var total: int = 0
	if inventory.collectibles.has(_type):
		total += inventory.collectibles[_type]

	if inventory.player_state.total_collectibles.has(_type):
		total += inventory.player_state.total_collectibles[_type]
	return total


func _render_health_value(_health: float) -> String:
	var content: String = ""
	for i in range(int(_health)):
		content += "■"
	return str(content)

func update_ui() -> void:
	%StatusText.text = ""
	%HealthValue.text = _render_health_value(health_component.current_health)
	if health_component.is_dead:
		%StatusText.text = "You died!"

	for slot in slots:
		var _slot: SlotWidget = slot
		_slot.set_quantity(slot.inventory_slot.current_blocks, slot.inventory_slot.MAX_BLOCKS)
		if _slot.inventory_slot.is_selected:
			_slot.modulate = Color(1, 1, 1)
		else:
			_slot.modulate = Color(0.5, 0.5, 0.5)




func _on_collectible_added(_play_sfx:bool = true) -> void:
	for collectible in CollectibleBase.CollectibleType.values():
		var total: int = _get_total_collectible_amount(collectible)
		if total > 0:
			if not collectible_widgets.has(collectible):
				var collectible_widget: CollectibleWidget = preload(collectible_widget_path).instantiate() as CollectibleWidget
				%Collectibles.add_child(collectible_widget)
				collectible_widgets[collectible] = collectible_widget
				collectible_widget.set_texture(CollectibleBase.IconMap[collectible])
			collectible_widgets[collectible].update_value(total)
	if _play_sfx:
		collectible_sfx_player.play()
	
func _on_damage(_amount: float) -> void:
	update_ui()


func _on_heal(_amount: float) -> void:
	update_ui()


func _on_death():
	death_sfx_player.play()
	update_ui()


func assign_health_component(_health_component: HealthComponent) -> void:
	health_component = _health_component
	health_component.OnDamage.connect(_on_damage)
	health_component.OnDeath.connect(_on_death)
	health_component.OnHeal.connect(_on_heal)


func assign_inventory(_inventory: Inventory) -> void:
	collectible_widgets = Dictionary()
	inventory = _inventory
	for slot in inventory.slots_map.values():
		slot.quantity_changed.connect(update_ui)
	inventory.slot_switched.connect(update_ui)
	inventory.blocks_full.connect(warn_block_full)
	inventory.collectible_added.connect(_on_collectible_added.bind(true))
	
	
	var _slots: HBoxContainer = %Slots
	slots = []
	for child in _slots.get_children():
		child.queue_free()

	var _collectibles: HBoxContainer = %Collectibles
	for child in _collectibles.get_children():
		child.queue_free()

	for slot in inventory.slots_map.values():
		var _islot: InventorySlot = slot as InventorySlot
		var slot_ui := preload(slot_widget_path).instantiate() as SlotWidget
		_slots.add_child(slot_ui)
		slot_ui.set_texture(_islot.get_texture())
		slot_ui.inventory_slot = _islot
		slots.append(slot_ui)
	
	_on_collectible_added(false)