extends CharacterBody2D
class_name VoidBrute

@export var max_hp: float = 90.0
var hp: float = 90.0
@export var speed: float = 65.0
@export var damage: float = 24.0
var gravity: float = 980.0

@onready var sprite: Sprite2D = $Sprite2D
var anim_timer: float = 0.0
var attack_cooldown: float = 0.0
var slam_timer: float = 0.0
var is_slamming: bool = false

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if slam_timer > 0.0:
		slam_timer -= delta

	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		var dx = player.global_position.x - global_position.x

		# Special ground slam when close
		if dist < 85.0 and slam_timer <= 0.0 and is_on_floor():
			perform_ground_slam(player)
		elif not is_slamming:
			if abs(dx) > 20.0:
				velocity.x = sign(dx) * speed
				sprite.flip_h = dx < 0
			else:
				velocity.x = 0
				if attack_cooldown <= 0.0:
					attack_cooldown = 1.2
					if player.has_method("take_damage"):
						player.take_damage(damage, global_position)
	else:
		velocity.x = 0

	move_and_slide()

	# Animation
	anim_timer += delta * 5.0
	sprite.frame = int(anim_timer) % 4

func perform_ground_slam(player: Node2D) -> void:
	slam_timer = 3.5
	is_slamming = true
	velocity.y = -220.0 # Small leap
	AudioManager.play_sfx("flame_burst", 0.7)
	GameManager.request_comic_popup("BOOM", global_position + Vector2(0, -15))

	var tween = create_tween()
	tween.tween_interval(0.4)
	tween.tween_callback(func():
		is_slamming = false
		if is_instance_valid(self):
			AudioManager.play_sfx("shatter", 0.8)
			GameManager.request_comic_popup("CRACK", global_position)
			# Shockwave damage
			if is_instance_valid(player) and global_position.distance_to(player.global_position) < 95.0:
				if player.has_method("take_damage"):
					player.take_damage(damage * 1.2, global_position)
	)

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	hp -= amount
	AudioManager.play_sfx("hit", 0.9)
	GameManager.request_comic_popup("CRACK", global_position)

	# Brute has high mass, minimal knockback
	if from_pos != Vector2.ZERO:
		var dir = (global_position - from_pos).normalized()
		velocity += Vector2(dir.x * 60.0, -40.0)

	var tween = create_tween()
	modulate = Color(2.5, 0.4, 0.4, 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)

	if hp <= 0.0:
		die()

func die() -> void:
	AudioManager.play_sfx("shatter", 0.9)
	GameManager.request_comic_popup("BOOM", global_position)
	GameManager.score += 150
	queue_free()
