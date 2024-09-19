extends Node
class_name PlayerState

signal switch_to_gamepad
signal switch_to_mouse_and_keyboard


var selected_slot: BlockBase.BlockType = BlockBase.BlockType.SIMPLE
var is_using_mouse_and_keyboard: bool = true
var current_player: Player
# map of collectible amount { CollectibleBase.CollectibleType: int }
var total_collectibles: Dictionary # 


func reset() -> void:
	selected_slot = BlockBase.BlockType.SIMPLE
	total_collectibles = {}


func add_collectible(_type: CollectibleBase.CollectibleType) -> void:
	if is_instance_valid(current_player):
		current_player.inventory.add_collectible(_type)


func _add_collectible_amount(_type: CollectibleBase.CollectibleType, _amount: int) -> void:
	if total_collectibles.has(_type):
		total_collectibles[_type] += _amount
	else:
		total_collectibles[_type] = _amount


func commit_collectibles() -> void:
	if is_instance_valid(current_player):
		for collectible in current_player.inventory.collectibles.keys():
			_add_collectible_amount(collectible, current_player.inventory.collectibles[collectible])


func switch_slot(_block_type: BlockBase.BlockType) -> void:
	selected_slot = _block_type


func asign_player(_player: Player) -> void:
	current_player = _player


func display_player_gamepad_crosshair(_display) -> void:
	if is_instance_valid(current_player):
		current_player.crosshair.visible = _display


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		is_using_mouse_and_keyboard = true
		display_player_gamepad_crosshair(false)
		switch_to_mouse_and_keyboard.emit()

	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		is_using_mouse_and_keyboard = false
		display_player_gamepad_crosshair(true)
		switch_to_gamepad.emit()
