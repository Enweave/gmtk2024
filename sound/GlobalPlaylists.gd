extends RefCounted

class_name GlobalPlaylists

enum bgms {
	INTRO,
	MAIN,
	LOSE,
	WIN
}

const bgm_map: Dictionary = {
	bgms.INTRO: "res://sound/gmtk2 2024-08-20 2158.mp3",
	bgms.MAIN: "res://sound/gmtk2 2024-08-20 2158.mp3",
	bgms.LOSE: "res://sound/sfx/death/death-bounce-2.mp3 ",
	bgms.WIN: "res://sound/bgm/jingles/win jingle Master-bounce-1.mp3"
}