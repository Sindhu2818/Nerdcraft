extends StaticBody2D
class_name VoidStone

@export var max_hp: float = 80.0
var hp: float = 80.0
@export var spawn_interval: float = 6.0
@export var spawn_brutes: bool = false
@export var max_spawns: int = 5

var current_spawns: int = 0
var spawn_timer: float = 2.0
var is_destroyed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var health_bar: ProgressBar = $HealthBar

var lurker_scene = preload("res://scenes/enemies/void_lurker.tscn")
var brute_scene = preload("res://scenes/enemies/void_brute.tscn")

var anim_timer: float = 0.0

func _ready() -> void:
	add_to_group("void_stones")
	hp = max_hp
	if health_bar:
		health_bar.max_value = max_hp
		health_bar.value = hp

func _process(delta: float) -> void:
	if is_destroyed:
		return

	# Idle pulse animation
	anim_timer += delta * 4.0
	sprite.frame = int(anim_timer) % 4

	# Spawner timer
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = spawn_interval
		if current_spawns < max_spawns:
			spawn_wave()

func spawn_wave() -> void:
	current_spawns += 1
	AudioManager.play_sfx("flame_burst", 0.8)
	GameManager.request_comic_popup("BOOM", global_position + Vector2(0, -25))

	var offset_x = -35.0 if randf() < 0.5 else 35.0
	var spawn_pos = global_position + Vector2(offset_x, 0)

	var enemy_to_spawn = brute_scene if (spawn_brutes and randf() < 0.4) else lurker_scene
	var enemy = enemy_to_spawn.instantiate()
	enemy.global_position = spawn_pos
	get_parent().add_child(enemy)

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	if is_destroyed:
		return

	hp -= amount
	if health_bar:
		health_bar.value = hp

	AudioManager.play_sfx("hit", randf_range(0.9, 1.1))
	GameManager.request_comic_popup("CRACK", global_position + Vector2(randf_range(-10, 10), -20))

	# Shake tween
	var tween = create_tween()
	var orig_pos = sprite.position
	tween.tween_property(sprite, "position", orig_pos + Vector2(randf_range(-4, 4), randf_range(-2, 2)), 0.04)
	tween.tween_property(sprite, "position", orig_pos, 0.04)
	modulate = Color(2.5, 0.5, 2.5, 1.0)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)

	if hp <= 0.0:
		shatter()

func shatter() -> void:
	if is_destroyed:
		return
	is_destroyed = true

	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)

	# Notify Game Manager
	GameManager.destroy_stone(global_position)

	# Dramatic shatter animation
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.6, 1.6), 0.15)
	tween.parallel().tween_property(light, "energy", 4.0, 0.15)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
