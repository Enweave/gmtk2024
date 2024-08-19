extends MainMenu

func _ready():
	super._ready()
	GlobalSoundPlayer.play_bgm(GlobalPlaylists.bgms.INTRO)