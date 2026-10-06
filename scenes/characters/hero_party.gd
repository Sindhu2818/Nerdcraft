extends Node2D
class_name HeroParty

@onready var alex: Hero = $Alex
@onready var athena: Hero = $Athena
@onready var kiri: Hero = $Kiri
@onready var camera: Camera2D = $Camera2D

var heroes: Array[Hero] = []
var active_index: int = 0
var shake_amount: float = 0.0
var shake_decay: float = 5.0

func _ready() -> void:
	heroes = [alex, athena, kiri]

	# Connect to GameManager signals
	GameManager.hero_swapped.connect(_on_hero_swapped)

	# Initial hero setup
	set_active_hero(GameManager.active_hero_index, false)

	# Position party initially together
	if heroes.size() > 0:
		for i in range(1, heroes.size()):
			heroes[i].global_position = heroes[0].global_position + Vector2(-30 * i, 0)

func _process(delta: float) -> void:
	# Camera follow active hero
	var active_hero = get_active_hero()
	if active_hero:
		camera.global_position = camera.global_position.lerp(active_hero.global_position, 10.0 * delta)

	# Screen shake
	if shake_amount > 0:
		shake_amount = max(0.0, shake_amount - shake_decay * delta)
		camera.offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		camera.offset = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("swap_next") or event.is_action_pressed("swap_hero") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_TAB or event.keycode == KEY_E)):
		cycle_next_hero()
	elif event.is_action_pressed("swap_prev") or event.is_action_pressed("swap_hero_prev") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q):
		cycle_prev_hero()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			set_active_hero(0)
		elif event.keycode == KEY_2:
			set_active_hero(1)
		elif event.keycode == KEY_3:
			set_active_hero(2)

func cycle_next_hero() -> void:
	var next_idx = (active_index + 1) % heroes.size()
	set_active_hero(next_idx)

func cycle_prev_hero() -> void:
	var prev_idx = (active_index - 1 + heroes.size()) % heroes.size()
	set_active_hero(prev_idx)

func set_active_hero(index: int, play_sound: bool = true) -> void:
	if index < 0 or index >= heroes.size():
		return

	var old_active = get_active_hero()
	var new_active = heroes[index]

	# Transfer position so active switch feels instantaneous and seamless
	if old_active and old_active != new_active:
		var target_pos = old_active.global_position
		var current_vel = old_active.velocity
		new_active.global_position = target_pos
		new_active.velocity = current_vel
		old_active.global_position += Vector2(-25 if not old_active.sprite.flip_h else 25, 0)

	active_index = index
	GameManager.active_hero_index = index

	for i in range(heroes.size()):
		heroes[i].is_active = (i == active_index)

	if play_sound:
		AudioManager.play_sfx("switch", 1.0)
		GameManager.request_comic_popup("WHOOSH", new_active.global_position)
		add_screen_shake(3.0)
		GameManager.hero_swapped.emit(GameManager.hero_names[index], index)

func _on_hero_swapped(hero_name: String, hero_index: int) -> void:
	if active_index != hero_index:
		set_active_hero(hero_index, false)

func get_active_hero() -> Hero:
	if active_index >= 0 and active_index < heroes.size():
		return heroes[active_index]
	return null

func get_leader_position() -> Vector2:
	var leader = get_active_hero()
	return leader.global_position if leader else global_position

func get_follower_target_position(follower: Hero) -> Vector2:
	var leader = get_active_hero()
	if not leader or follower == leader:
		return global_position

	var leader_facing_dir = -1.0 if leader.sprite.flip_h else 1.0
	# Follower offset behind the leader
	var follower_order = 1
	var other_followers: Array[Hero] = []
	for h in heroes:
		if h != leader:
			other_followers.append(h)

	if other_followers.size() > 1 and follower == other_followers[1]:
		follower_order = 2

	var dist_behind = 32.0 * follower_order
	var target = leader.global_position - Vector2(leader_facing_dir * dist_behind, 0)

	if follower.hero_type == "Kiri":
		# Kiri hovers slightly above leader
		target += Vector2(0, -22.0)

	return target

func add_screen_shake(amount: float) -> void:
	shake_amount = min(shake_amount + amount, 14.0)
