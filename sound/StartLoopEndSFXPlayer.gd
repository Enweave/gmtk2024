@tool
extends SFXPlayerBase
class_name StartLoopEndSFXPlayer
# class for sound fx player. 
# Plays a start sound, then loops a sound, then plays an end sound.
# if start sound is not provided, it will start with loop sound.
# if loop sound is not provided, it will not play anything at all.
# if end sound is not provided, it will stop after loop sound.

## optional sound to play at the start of the sound 
@export var start_sound: AudioStream = null
## main sound to loop
@export var loop_sound: AudioStream = null
## optional sound to play at the end of the sound
@export var end_sound: AudioStream = null
## time in seconds to subtract from the end of start sound (for more seamless transition)
@export var start_sound_cutout_sec: float = 0.0


func _ready():
	_create_new_player()


func start():
	audio_stream_player.stop()
	if start_sound != null:
		audio_stream_player.stream = start_sound
		audio_stream_player.play()

		# deliverately not using await start_sound_duration.finished cuz it does not provide seampless transition
		var start_sound_duration: float = start_sound.get_length()
		await get_tree().create_timer(start_sound_duration-start_sound_cutout_sec).timeout

	if loop_sound == null:
		return
	audio_stream_player.stream = loop_sound
	audio_stream_player.play()


func stop():
	audio_stream_player.stop()
	if end_sound == null:
		return
	audio_stream_player.stream = end_sound
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.stop()
