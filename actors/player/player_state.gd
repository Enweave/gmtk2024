extends Node

class_name PlayerState

var egg_count = 0
var cube_count = 0

var selected_slot: BlockBase.BlockType = BlockBase.BlockType.SIMPLE
var is_using_mouse_and_keyboard: bool = true
var current_player: Player

func reset() -> void:
	selected_slot = BlockBase.BlockType.SIMPLE
	
func switch_slot(_block_type: BlockBase.BlockType) -> void:
	selected_slot = _block_type
	
func asign_player(_player: Player) -> void:
	current_player = _player

func display_player_gamepad_crosshair(_display) -> void:
	if current_player:
		current_player.crosshair.visible = _display

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		is_using_mouse_and_keyboard = true
		display_player_gamepad_crosshair(false)
		
	if event is InputEventJoypadButton:
		is_using_mouse_and_keyboard = false
		display_player_gamepad_crosshair(true)