@tool
extends SFXPlayerBase
class_name RandomSFXPlayer
# class for sound fx player. Plays random sound fx from a list.


@export var files: Array[String]

## Prefill files with any mp3 files in the directory.
@export_dir var directory: String:
	set(value):
		directory = value
		_refresh_files()


func _refresh_files() -> void:
	if not is_inside_tree(): return
	var dir_access: DirAccess = DirAccess.open(directory)
	if dir_access:
		files.clear()
		for file: String in dir_access.get_files():
			if not file.ends_with(".mp3"):
				continue
			files.append(directory + "/" + file)


var last_played_index: int = -1


func _ready():
	_create_new_player()


func play_random_sound():
	if files.size() > 0:
		var random_index: int = randi() % files.size()
		if random_index == last_played_index:
			random_index = (random_index + 1) % files.size()
		audio_stream_player.stream = load(files[random_index])
		audio_stream_player.play()
		last_played_index = random_index
	else:
		push_error("No sound files found in directory: " + directory)
