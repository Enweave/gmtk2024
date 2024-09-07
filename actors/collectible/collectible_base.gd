extends Node

class_name CollectibleBase
var is_collected: bool = false
var collectible_type: CollectibleType = CollectibleType.EGG

enum CollectibleType {
	EGG,
	CUBE
}

const IconMap : Dictionary = {
	CollectibleType.EGG: "res://assets/spritesheets/props/EGG_icon.png",
	CollectibleType.CUBE: "res://assets/spritesheets/props/portal-cube_icon.png"
} 

const NameMap : Dictionary = {
	CollectibleType.EGG: "Memory core",
	CollectibleType.CUBE: "Portal cube"
}

const TotalAmountMap : Dictionary = {
	CollectibleType.EGG: 12,
	CollectibleType.CUBE: 1
}


func collect() -> void:
	if is_collected:
		return
	is_collected = true
	var player_state: PlayerState = GlobalPlayerState
	player_state.add_collectible(self.collectible_type)
