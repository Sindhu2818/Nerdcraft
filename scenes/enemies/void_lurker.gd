extends CharacterBody2D
class_name VoidLurker

@export var max_hp: float = 35.0
var hp: float = 35.0
@export var speed: float = 120.0
@export var damage: float = 12.0
var gravity: float = 980.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_timer: float = 0.0

var attack_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# Hunt player
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var dx = player.global_position.x - global_position.x
		if abs(dx) > 16.0:
			velocity.x = sign(dx) * speed
			sprite.flip_h = dx < 0
		else:
			velocity.x = 0
			# Melee hit
			if attack_cooldown <= 0.0:
				attack_cooldown = 1.0
				if player.has_method("take_damage"):
					player.take_damage(damage, global_position)
	else:
		velocity.x = 0

	move_and_slide()

	# Animation
	anim_timer += delta * 8.0
	sprite.frame = int(anim_timer) % 4

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	hp -= amount
	AudioManager.play_sfx("hit", randf_range(1.1, 1.3))
	GameManager.request_comic_popup("CRACK", global_position)

	# Knockback
	if from_pos != Vector2.ZERO:
		var dir = (global_position - from_pos).normalized()
		velocity += Vector2(dir.x * 160.0, -120.0)

	# Flash white/red
	var tween = create_tween()
	modulate = Color(3.0, 0.4, 0.4, 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)

	if hp <= 0.0:
		die()

func die() -> void:
	AudioManager.play_sfx("shatter", 1.2)
	GameManager.request_comic_popup("BOOM", global_position)
	GameManager.score += 50
	queue_free()
