extends Area2D
class_name ExitPortal

@export var is_open: bool = false
@export var target_stage: int = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameManager.void_stone_destroyed.connect(_on_void_stone_destroyed)
	update_portal_state(GameManager.stones_remaining == 0)

func _process(delta: float) -> void:
	if is_open:
		# Rotating light pulse
		light.energy = 1.6 + sin(Time.get_ticks_msec() * 0.008) * 0.4
		sprite.rotation += 2.0 * delta

func _on_void_stone_destroyed(remaining: int, _total: int) -> void:
	if remaining <= 0:
		open_portal()

func open_portal() -> void:
	if is_open:
		return
	is_open = true
	update_portal_state(true)
	AudioManager.play_sfx("victory", 1.0)
	GameManager.request_comic_popup("LIGHT", global_position + Vector2(0, -25))

func update_portal_state(open: bool) -> void:
	is_open = open
	if is_open:
		modulate = Color(1.0, 0.95, 0.6, 1.0)
		light.enabled = true
		light.energy = 1.8
		label.text = "[PORTAL OPEN! ENTER]"
	else:
		modulate = Color(0.4, 0.4, 0.5, 0.4)
		light.enabled = false
		label.text = "[LOCKED - DESTROY ALL BEACONS]"

func _on_body_entered(body: Node2D) -> void:
	if is_open and body.is_in_group("player"):
		GameManager.level_completed.emit()
