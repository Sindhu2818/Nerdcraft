extends Node

# Game Manager Singleton
signal hero_swapped(hero_name: String, hero_index: int)
signal hero_health_changed(current_hp: float, max_hp: float)
signal hero_energy_changed(current_energy: float, max_energy: float)
signal void_stone_destroyed(remaining: int, total: int)
signal comic_popup_requested(popup_type: String, global_pos: Vector2)
signal level_completed()
signal game_over_triggered()
signal light_level_changed(light_percent: float)

var current_stage: int = 1
const MAX_STAGES: int = 3

var total_stones_in_level: int = 2
var stones_remaining: int = 2
var score: int = 0

# Heroes party: 0 = Alex (Light), 1 = Athena (Fire), 2 = Kiri (Wind)
var hero_names: Array[String] = ["Alex", "Athena", "Kiri"]
var active_hero_index: int = 0

var party_hp: float = 100.0
var party_max_hp: float = 100.0
var party_energy: float = 100.0
var party_max_energy: float = 100.0

var is_game_over: bool = false
var is_level_transitioning: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	# Passive energy regeneration
	if party_energy < party_max_energy and not is_game_over:
		party_energy = min(party_max_energy, party_energy + 20.0 * delta)
		hero_energy_changed.emit(party_energy, party_max_energy)

func register_level(stage_num: int, total_stones: int) -> void:
	current_stage = stage_num
	total_stones_in_level = total_stones
	stones_remaining = total_stones
	is_game_over = false
	is_level_transitioning = false
	party_hp = party_max_hp
	party_energy = party_max_energy
	hero_health_changed.emit(party_hp, party_max_hp)
	hero_energy_changed.emit(party_energy, party_max_energy)
	void_stone_destroyed.emit(stones_remaining, total_stones_in_level)
	update_light_level()

func update_light_level() -> void:
	var restored_stones = total_stones_in_level - stones_remaining
	var light_percent: float = 0.25 # Base ambient gloom
	if total_stones_in_level > 0:
		light_percent = 0.25 + 0.75 * (float(restored_stones) / float(total_stones_in_level))
	light_level_changed.emit(light_percent)

func destroy_stone(global_pos: Vector2 = Vector2.ZERO) -> void:
	if stones_remaining <= 0:
		return
	stones_remaining -= 1
	score += 500
	void_stone_destroyed.emit(stones_remaining, total_stones_in_level)
	update_light_level()

	AudioManager.play_sfx("shatter", 1.0, 4.0)
	request_comic_popup("SHATTER", global_pos)

	if stones_remaining <= 0:
		# Level cleared!
		AudioManager.play_sfx("victory", 1.0, 2.0)
		request_comic_popup("LIGHT", global_pos + Vector2(0, -40))
		level_completed.emit()

func request_comic_popup(popup_type: String, global_pos: Vector2) -> void:
	comic_popup_requested.emit(popup_type, global_pos)

func damage_hero(amount: float, hit_pos: Vector2 = Vector2.ZERO) -> void:
	if is_game_over:
		return
	party_hp = max(0.0, party_hp - amount)
	hero_health_changed.emit(party_hp, party_max_hp)
	AudioManager.play_sfx("hit")
	request_comic_popup("CRACK", hit_pos)

	if party_hp <= 0.0:
		trigger_game_over()

func heal_hero(amount: float) -> void:
	party_hp = min(party_max_hp, party_hp + amount)
	hero_health_changed.emit(party_hp, party_max_hp)

func consume_energy(amount: float) -> bool:
	if party_energy >= amount:
		party_energy -= amount
		hero_energy_changed.emit(party_energy, party_max_energy)
		return true
	return false

func swap_hero(dir: int) -> void:
	active_hero_index = (active_hero_index + dir) % hero_names.size()
	if active_hero_index < 0:
		active_hero_index = hero_names.size() - 1
	AudioManager.play_sfx("switch")
	hero_swapped.emit(hero_names[active_hero_index], active_hero_index)

func get_active_hero_name() -> String:
	return hero_names[active_hero_index]

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over_triggered.emit()

func next_stage() -> void:
	if is_level_transitioning:
		return
	is_level_transitioning = true
	current_stage += 1
	if current_stage > MAX_STAGES:
		# Game won! Victory screen
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/victory_screen.tscn")
	else:
		var next_scene = "res://scenes/levels/level%d.tscn" % current_stage
		get_tree().call_deferred("change_scene_to_file", next_scene)

func restart_stage() -> void:
	is_game_over = false
	var scene_path = "res://scenes/levels/level%d.tscn" % current_stage
	get_tree().call_deferred("change_scene_to_file", scene_path)

func restart_game() -> void:
	current_stage = 1
	score = 0
	party_hp = party_max_hp
	party_energy = party_max_energy
	is_game_over = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/title_screen.tscn")
