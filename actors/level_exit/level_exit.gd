extends Node2D

class_name LevelExit

signal level_exit

func _on_area_2d_body_entered(body):
	if body is Player:
		var player_state: PlayerState = GlobalPlayerState
		player_state.commit_collectibles()
		level_exit.emit()