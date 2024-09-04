extends Node

class_name PlayerState

var selected_slot: BlockBase.BlockType = BlockBase.BlockType.SIMPLE
var is_using_mouse_and_keyboard: bool = true
var current_player: Player

var total_collectible_count: int = 0

func reset() -> void:
	selected_slot = BlockBase.BlockType.SIMPLE
	total_collectible_count = 0
	
func add_collectible(_node: Node) -> void:
	if is_instance_valid(current_player):
		current_player.inventory.add_collectible(_node)

func commit_collectibles() -> void:
	if is_instance_valid(current_player):
		total_collectible_count += current_player.inventory.collectible_count
	
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
		
	if event is InputEventJoypadButton:
		is_using_mouse_and_keyboard = false
		display_player_gamepad_crosshair(true)
