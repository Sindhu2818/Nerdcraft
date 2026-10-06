extends CharacterBody2D
class_name Hero

@export var hero_type: String = "Alex" # "Alex", "Athena", "Kiri"
@export var is_active: bool = false

# Movement parameters
var move_speed: float = 200.0
var jump_velocity: float = -380.0
var gravity: float = 980.0
var can_double_jump: bool = false
var has_double_jumped: bool = false

# Combat parameters
var attack_cooldown: float = 0.0
var skill_cooldown: float = 0.0
var assist_attack_timer: float = 0.0

# Projectile scenes
var light_beam_scene = preload("res://scenes/projectiles/light_beam.gd")
var flame_burst_scene = preload("res://scenes/projectiles/flame_burst.gd")
var wind_blade_scene = preload("res://scenes/projectiles/wind_blade.gd")

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var anim_timer: float = 0.0
var walk_frame_index: int = 1
var is_casting: bool = false
var cast_timer: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	setup_hero_stats()

func setup_hero_stats() -> void:
	match hero_type:
		"Alex":
			move_speed = 190.0
			jump_velocity = -370.0
			sprite.texture = preload("res://assets/sprites/characters/alex/spritesheet.png")
			light.color = Color(1.0, 0.95, 0.65, 1.0)
			light.texture_scale = 1.4
			light.energy = 1.3
		"Athena":
			move_speed = 210.0
			jump_velocity = -360.0
			sprite.texture = preload("res://assets/sprites/characters/athena/spritesheet.png")
			light.color = Color(1.0, 0.5, 0.2, 1.0)
			light.texture_scale = 1.1
			light.energy = 1.4
		"Kiri":
			move_speed = 230.0
			jump_velocity = -410.0
			can_double_jump = true
			sprite.texture = preload("res://assets/sprites/characters/kiri/spritesheet.png")
			light.color = Color(0.5, 0.95, 0.9, 1.0)
			light.texture_scale = 1.2
			light.energy = 1.2

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	GameManager.damage_hero(amount, from_pos)
	AudioManager.play_sfx("hit", 1.0)
	# Knockback
	if from_pos != Vector2.ZERO:
		var knock_dir = (global_position - from_pos).normalized()
		velocity += Vector2(knock_dir.x * 220.0, -180.0)
	# Hit flash
	var tween = create_tween()
	modulate = Color(2.5, 0.5, 0.5, 1.0)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if skill_cooldown > 0.0:
		skill_cooldown -= delta
	if cast_timer > 0.0:
		cast_timer -= delta
		if cast_timer <= 0.0:
			is_casting = false

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
		move_and_slide()
		update_animation(delta)
		return

	if is_active:
		handle_active_input(delta)
	else:
		handle_companion_behavior(delta)

	move_and_slide()
	update_animation(delta)

func handle_active_input(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		# Kiri floats softly
		if hero_type == "Kiri" and velocity.y > 0 and Input.is_action_pressed("jump"):
			velocity.y += (gravity * 0.4) * delta
		else:
			velocity.y += gravity * delta
	else:
		has_double_jumped = false

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
			AudioManager.play_sfx("jump")
		elif can_double_jump and not has_double_jumped:
			velocity.y = jump_velocity * 0.9
			has_double_jumped = true
			AudioManager.play_sfx("wind_dash", 1.2)
			GameManager.request_comic_popup("WHOOSH", global_position)

	# Horizontal movement
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = dir * move_speed
		sprite.flip_h = dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 10.0 * delta)

	# Attacks
	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		perform_primary_attack()
	elif Input.is_action_just_pressed("skill") and skill_cooldown <= 0.0:
		perform_skill()

func perform_primary_attack() -> void:
	attack_cooldown = 0.25
	is_casting = true
	cast_timer = 0.18
	var spawn_pos = global_position + Vector2(-15 if sprite.flip_h else 15, -6)
	var shoot_dir = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT

	var scene_root = get_tree().current_scene if get_tree().current_scene else get_parent()
	var proj_scene: PackedScene = null

	match hero_type:
		"Alex":
			AudioManager.play_sfx("light_blast")
			proj_scene = preload("res://scenes/projectiles/light_beam.tscn")
		"Athena":
			AudioManager.play_sfx("flame_burst")
			proj_scene = preload("res://scenes/projectiles/flame_burst.tscn")
		"Kiri":
			AudioManager.play_sfx("wind_dash", 1.1)
			proj_scene = preload("res://scenes/projectiles/wind_blade.tscn")

	if proj_scene:
		var proj = proj_scene.instantiate()
		proj.direction = shoot_dir
		scene_root.add_child(proj)
		proj.global_position = spawn_pos

func perform_skill() -> void:
	match hero_type:
		"Alex": # Radiant Heal & Flash
			if GameManager.consume_energy(35.0):
				skill_cooldown = 2.0
				is_casting = true
				cast_timer = 0.3
				GameManager.heal_hero(25.0)
				AudioManager.play_sfx("light_blast", 1.3)
				GameManager.request_comic_popup("LIGHT", global_position + Vector2(0, -20))
				# Temporary huge light burst
				var tween = create_tween()
				tween.tween_property(light, "energy", 3.0, 0.1)
				tween.tween_property(light, "energy", 1.3, 0.4)
		"Athena": # Flame Dash / Nova
			if GameManager.consume_energy(30.0):
				skill_cooldown = 1.5
				is_dashing = true
				dash_timer = 0.22
				var dash_dir = -1.0 if sprite.flip_h else 1.0
				velocity = Vector2(dash_dir * 550.0, -40.0)
				AudioManager.play_sfx("flame_burst", 0.9)
				GameManager.request_comic_popup("BOOM", global_position)
				# Spawn flame hitbox
				var proj = preload("res://scenes/projectiles/flame_burst.tscn").instantiate()
				proj.direction = Vector2(dash_dir, 0)
				var scene_root = get_tree().current_scene if get_tree().current_scene else get_parent()
				scene_root.add_child(proj)
				proj.global_position = global_position
		"Kiri": # Cyclone Launch
			if GameManager.consume_energy(25.0):
				skill_cooldown = 1.2
				velocity.y = -520.0
				AudioManager.play_sfx("wind_dash", 1.3)
				GameManager.request_comic_popup("WHOOSH", global_position)
				# Push back enemies
				var enemies = get_tree().get_nodes_in_group("enemies")
				for e in enemies:
					if e is CharacterBody2D and global_position.distance_to(e.global_position) < 140.0:
						var push = (e.global_position - global_position).normalized() * 320.0
						e.velocity += push

func handle_companion_behavior(delta: float) -> void:
	var party = get_parent()
	if not party or not party.has_method("get_leader_position"):
		return

	var target_pos: Vector2 = party.get_follower_target_position(self)
	var dist = global_position.distance_to(target_pos)

	if hero_type == "Kiri":
		# Kiri hovers smoothly like a wind spirit
		var hover_offset = Vector2(0, sin(Time.get_ticks_msec() * 0.005) * 6.0)
		global_position = global_position.lerp(target_pos + hover_offset, 6.0 * delta)
		sprite.flip_h = target_pos.x < global_position.x
		velocity = Vector2.ZERO
	else:
		# Ground followers run & jump toward leader
		if not is_on_floor():
			velocity.y += gravity * delta

		var dx = target_pos.x - global_position.x
		if abs(dx) > 12.0:
			var dir_sign = sign(dx)
			velocity.x = dir_sign * move_speed * 0.85
			sprite.flip_h = dir_sign < 0

			# Jump over small obstacles if blocked
			if is_on_floor() and is_on_wall():
				velocity.y = jump_velocity * 0.9
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * 8.0 * delta)

	# Assist Attack AI
	assist_attack_timer += delta
	if assist_attack_timer >= 1.6:
		assist_attack_timer = 0.0
		var nearby_enemy = find_closest_enemy(150.0)
		if nearby_enemy:
			sprite.flip_h = nearby_enemy.global_position.x < global_position.x
			perform_primary_attack()

func find_closest_enemy(max_dist: float) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var min_d = max_dist
	for e in enemies:
		if is_instance_valid(e):
			var d = global_position.distance_to(e.global_position)
			if d < min_d:
				min_d = d
				closest = e
	return closest

func update_animation(delta: float) -> void:
	if is_casting:
		sprite.frame = 5 # Cast frame
		return

	if not is_on_floor() and hero_type != "Kiri":
		sprite.frame = 4 # Jump frame
		return

	if hero_type == "Kiri":
		# Kiri floating cycle
		anim_timer += delta * 6.0
		sprite.frame = int(anim_timer) % 4
		return

	# Ground walk cycle
	if abs(velocity.x) > 10.0:
		anim_timer += delta * 9.0
		var walk_frames = [1, 2, 3]
		sprite.frame = walk_frames[int(anim_timer) % 3]
	else:
		sprite.frame = 0 # Idle frame
