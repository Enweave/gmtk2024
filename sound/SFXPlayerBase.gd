extends Node

class_name SFXPlayerBase

enum TypeOfPlayer {
	AUDIO_STREAM_PLAYER_2D,
	AUDIO_STREAM_PLAYER
}
## Pick type depending on scene.
## AUDIO_STREAM_PLAYER for UI, AUDIO_STREAM_PLAYER_2D for 2D scenes.
@export var type_of_player: TypeOfPlayer = TypeOfPlayer.AUDIO_STREAM_PLAYER_2D
@export var bus_name: String = "SFX"

## Volume of the player at initialization.
## To lover the volume of the player, set it to a negative value.
@export var volume_db: float = 0.0

## The factor for the attenuation effect at initialization. 
## Higher values make the sound audible over a larger distance.
@export var unit_size: float = 10.0

## The maximum distance at which the sound is audible at initialization.
@export var max_distance: float = 30.0

## Sets the absolute maximum of the sound level, in decibels at initialization.
@export var max_db: float = -2

var audio_stream_player

func _create_new_player():
	if type_of_player == TypeOfPlayer.AUDIO_STREAM_PLAYER_2D:
		audio_stream_player = AudioStreamPlayer2D.new()
#		audio_stream_player.attenuation_filter_cutoff_hz = 20500
	else:
		audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.autoplay = false
	audio_stream_player.bus = bus_name
	audio_stream_player.volume_db = volume_db

#	audio_stream_player.max_db = max_db
#	audio_stream_player.unit_size = unit_size

	# https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html#enum-audiostreamplayer3d-attenuationmodel
#	audio_stream_player.attenuation_model = 1 # ATTENUATION_INVERSE_SQUARE_DISTANCE
	add_child(audio_stream_player)
	
