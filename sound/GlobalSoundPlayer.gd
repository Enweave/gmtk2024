extends Node

var sound_player: AudioStreamPlayer
var last_bgm: GlobalPlaylists.bgms = GlobalPlaylists.bgms.LOSE


func _ready():
	sound_player = AudioStreamPlayer.new()
	sound_player.bus = "Music"
	add_child(sound_player)


func play_bgm(bgm: GlobalPlaylists.bgms):
	if not bgm in GlobalPlaylists.bgm_map:
		return
	if last_bgm == bgm:
		return
	sound_player.stop()
	last_bgm = bgm
	sound_player.stream = load(GlobalPlaylists.bgm_map[bgm])
	sound_player.volume_db = -14
	sound_player.play()


func stop_bgm():
	sound_player.stop()
