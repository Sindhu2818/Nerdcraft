extends CharacterBody2D
class_name DemonKing

@export var max_hp: float = 300.0
var hp: float = 300.0
var gravity: float = 980.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var light: PointLight2D = $PointLight2D

var anim_timer: float = 0.0
var attack_timer: float = 2.0
var teleport_timer: float = 5.0
var summon_timer: float = 8.0
var phase: int = 1

var void_proj_scene = preload("res://scenes/projectiles/void_projectile.tscn")
var lurker_scene = preload("res://scenes/enemies/void_lurker.tscn")

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("bosses")
	hp = max_hp
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = hp

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

	anim_timer += delta * 6.0
	sprite.frame = int(anim_timer) % 4

	attack_timer -= delta
	teleport_timer -= delta
	summon_timer -= delta

	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		sprite.flip_h = player.global_position.x < global_position.x

		# Attack cycle
		if attack_timer <= 0.0:
			attack_timer = randf_range(2.0, 3.0) if phase == 1 else randf_range(1.4, 2.2)
			fire_void_barrage(player)

		# Teleport cycle
		if teleport_timer <= 0.0:
			teleport_timer = randf_range(5.0, 7.0)
			teleport_near_player(player)

		# Minion summon in Phase 2
		if hp < max_hp * 0.5 and summon_timer <= 0.0:
			summon_timer = 10.0
			summon_minions()

func fire_void_barrage(player: Node2D) -> void:
	AudioManager.play_sfx("flame_burst", 0.6)
	GameManager.request_comic_popup("BOOM", global_position + Vector2(0, -20))

	var angles = [-0.25, 0.0, 0.25]
	var base_dir = (player.global_position - global_position).normalized()
	for ang in angles:
		var p = void_proj_scene.instantiate()
		p.global_position = global_position + Vector2(0, -10)
		p.direction = base_dir.rotated(ang)
		get_parent().add_child(p)

func teleport_near_player(player: Node2D) -> void:
	AudioManager.play_sfx("wind_dash", 0.7)
	GameManager.request_comic_popup("WHOOSH", global_position)

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		var side = -1.0 if randf() < 0.5 else 1.0
		global_position = player.global_position + Vector2(side * 120.0, -10)
		AudioManager.play_sfx("wind_dash", 0.8)
		GameManager.request_comic_popup("WHOOSH", global_position)
	)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func summon_minions() -> void:
	AudioManager.play_sfx("shatter", 1.0)
	GameManager.request_comic_popup("CRACK", global_position + Vector2(0, -30))
	for i in [-1, 1]:
		var m = lurker_scene.instantiate()
		m.global_position = global_position + Vector2(i * 50.0, -10.0)
		get_parent().add_child(m)

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	hp -= amount
	if health_bar:
		health_bar.value = hp
	AudioManager.play_sfx("hit", 0.8)
	GameManager.request_comic_popup("CRACK", global_position)

	var tween = create_tween()
	modulate = Color(3.0, 0.4, 0.4, 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.12)

	if hp <= 0.0:
		die()

func die() -> void:
	AudioManager.play_sfx("shatter", 0.7)
	AudioManager.play_sfx("victory", 1.0)
	GameManager.request_comic_popup("SHATTER", global_position)
	GameManager.request_comic_popup("LIGHT", global_position + Vector2(0, -35))
	GameManager.score += 2000

	# Trigger stage 3 level completion!
	GameManager.level_completed.emit()
	queue_free()
