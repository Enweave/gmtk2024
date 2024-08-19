extends RefCounted

class_name GlobalPlaylists

enum bgms {
	INTRO,
	MAIN,
	LOSE,
	WIN
}

const bgm_map: Dictionary = {
	bgms.INTRO: "res://sound/bgm/music/pj15-bgm0-bpm196 intro.mp3",
	bgms.MAIN: "res://sound/bgm/music/pj15-bgm0-bpm196 main.mp3",
	bgms.LOSE: "res://sound/bgm/jingles/death Master-bounce-2.mp3",
	bgms.WIN: "res://sound/bgm/jingles/win jingle Master-bounce-1.mp3"
}