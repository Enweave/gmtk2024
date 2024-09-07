extends RefCounted

class_name GlobalPlaylists

enum bgms {
	INTRO,
	MAIN,
	LOSE,
	WIN
}

const bgm_map: Dictionary = {
	bgms.INTRO: "res://sound/bgm/gmtk-theme-1.mp3",
	bgms.MAIN: "res://sound/bgm/gmtk-theme-2.mp3",
	bgms.LOSE: "res://sound/sfx/death/death-bounce-2.mp3",
	bgms.WIN: "res://sound/bgm/gmtk-theme-1.mp3"
}