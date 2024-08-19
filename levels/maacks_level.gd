extends Node

class_name MaackLevel

# maacks template signals
signal level_won
signal level_lost

@export var bgm: GlobalPlaylists.bgms = GlobalPlaylists.bgms.MAIN

func _ready():
	GlobalSoundPlayer.play_bgm(bgm)

func _on_level_exit_sensor_touched():
	level_won.emit()

func _on_player_death():
	level_lost.emit()
