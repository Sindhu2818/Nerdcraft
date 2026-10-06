extends Node

# Audio Manager: handles SFX and looping music
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE = 8

var sounds = {
	"jump": preload("res://assets/audio/sfx_jump.wav"),
	"light_blast": preload("res://assets/audio/sfx_light_blast.wav"),
	"flame_burst": preload("res://assets/audio/sfx_flame_burst.wav"),
	"wind_dash": preload("res://assets/audio/sfx_wind_dash.wav"),
	"hit": preload("res://assets/audio/sfx_hit.wav"),
	"shatter": preload("res://assets/audio/sfx_shatter.wav"),
	"switch": preload("res://assets/audio/sfx_switch.wav"),
	"victory": preload("res://assets/audio/sfx_victory.wav")
}

var bgm_stream = preload("res://assets/audio/bgm_adventure.wav")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	music_player.volume_db = -6.0
	add_child(music_player)

	for i in range(SFX_POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		sfx_players.append(p)

	play_music()

func play_music() -> void:
	if music_player.stream != bgm_stream:
		music_player.stream = bgm_stream
	if not music_player.playing:
		music_player.play()

func play_bgm() -> void:
	play_music()

func stop_music() -> void:
	music_player.stop()

func play_sfx(sound_name: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name):
		return
	for player in sfx_players:
		if not player.playing:
			player.stream = sounds[sound_name]
			player.pitch_scale = pitch_scale + randf_range(-0.08, 0.08)
			player.volume_db = volume_db
			player.play()
			return
	# If all busy, use first
	sfx_players[0].stream = sounds[sound_name]
	sfx_players[0].pitch_scale = pitch_scale
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()
