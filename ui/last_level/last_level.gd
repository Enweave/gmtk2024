extends MaackLevel

func _on_button_pressed() -> void:
	level_won.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	var player_state: PlayerState = GlobalPlayerState
	var collectibles_container: Control = %CollectiblesVBoxContainer

	var game_ui: Node = get_tree().get_root().get_node_or_null("/root/GameUI")
	if game_ui:
		var existing_ui: Node = game_ui.get_node_or_null("%InGameUI")
		if existing_ui:
			existing_ui.queue_free()

	# empty container
	for child in collectibles_container.get_children():
		child.queue_free()

	for collectible_type in player_state.total_collectibles.keys():
		var collectible_widget: TotalCollectibleWidget = preload("res://ui/last_level/total_collectible_widget.tscn").instantiate()
		collectibles_container.add_child(collectible_widget)
		collectible_widget.render(collectible_type, player_state.total_collectibles[collectible_type], CollectibleBase.TotalAmountMap[collectible_type])