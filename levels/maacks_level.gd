extends Node

class_name MaackLevel

# maacks template signals
signal level_won
signal level_lost

@export var bgm: GlobalPlaylists.bgms = GlobalPlaylists.bgms.MAIN
@export var play_bgm: bool = true

func _ready():
	if play_bgm:
		GlobalSoundPlayer.play_bgm(bgm)
		
	for player in get_tree().get_nodes_in_group("player"):
		player.connect("death", _on_player_death)

	for level_exit in get_tree().get_nodes_in_group("level_exit"):
		level_exit.connect("level_exit", _on_level_exit_sensor_touched)	
	
func _on_level_exit_sensor_touched():
	level_won.emit()

func _on_player_death():
	level_lost.emit()
