extends "res://addons/maaacks_game_template/extras/scenes/WinScreen/WinScreen.gd"


func _ready():
	super._ready()
	GlobalSoundPlayer.play_bgm(GlobalPlaylists.bgms.WIN)
