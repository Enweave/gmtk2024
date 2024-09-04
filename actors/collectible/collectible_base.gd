extends Node

class_name CollectibleBase
var is_collected: bool = false

func collect() -> void:
	if is_collected:
		return
	is_collected = true
	var player_state: PlayerState = GlobalPlayerState
	player_state.add_collectible(self)
