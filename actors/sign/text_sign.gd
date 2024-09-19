extends Node2D

@export var text: String
@export var gamepad_text: String

var player_state: PlayerState

@onready var regex: RegEx = RegEx.new()


func _on_switch_to_mouse_and_keyboard() -> void:
	%Label.text = template_text(text, false)


func _on_switch_to_gamepad() -> void:
	var _text: String = text
	if gamepad_text != "":
		_text = gamepad_text
	%Label.text = template_text(_text, true)


func _cleanup_name(_name: String) -> String:
	return regex.sub(_name, "")


func _replace_text(_text: String, _action_name: String, _event: InputEvent) -> String:
	return _text.replace('{'+_action_name+"}", _cleanup_name(_event.as_text()))


func _is_gamepad_event(_event: InputEvent) -> bool:
	return _event is InputEventJoypadButton or _event is InputEventJoypadMotion


func template_text(_text: String, is_gamepad: bool = false) -> String:
	# Takes a string and replaces all the action names with their respective input event text

	var _template: String = _text

	for action_name in AppSettings.get_action_names():
		var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)

		if is_gamepad:
			action_events = action_events.filter(_is_gamepad_event)

		for event in action_events:
			_template = _replace_text(_template, action_name, event)

	return _template


func _ready()->void:
	regex.compile("\\(.*?\\)")

	player_state = GlobalPlayerState as PlayerState
	%Label.text = template_text(text, !player_state.is_using_mouse_and_keyboard)

	player_state.switch_to_gamepad.connect(_on_switch_to_gamepad)
	player_state.switch_to_mouse_and_keyboard.connect(_on_switch_to_mouse_and_keyboard)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		%Label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		%Label.visible = false
