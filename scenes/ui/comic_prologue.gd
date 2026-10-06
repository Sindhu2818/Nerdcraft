extends Control

@onready var texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TextureRect
@onready var text_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CaptionPanel/CaptionLabel
@onready var prompt_label: Label = $PanelContainer/MarginContainer/VBoxContainer/CaptionPanel/PromptLabel

var pages = [
	{
		"texture": preload("res://assets/comic/prologue_opening.png"),
		"text": "Chapter 0: The Shattered Realm\nWhen the Void descended, ancient Void Beacons drained the world's light, twisting reality into perpetual gloom.",
		"sfx": "shatter"
	},
	{
		"texture": preload("res://assets/comic/king_people_demon.png"),
		"text": "The Demon King Avatar seized the ancient kingdom, corrupting sacred lands with darkness and shadow beasts.",
		"sfx": "hit"
	},
	{
		"texture": preload("res://assets/comic/helpers_for_demon.png"),
		"text": "Three champions arose to restore the light:\nAlex the Light Wielder, Athena of the Sacred Flames, and Kiri the Wind Spirit.\nShatter the Void Stones to banish the dark!",
		"sfx": "victory"
	}
]

var current_page_index: int = 0

func _ready() -> void:
	AudioManager.play_bgm()
	show_page(0)

func show_page(index: int) -> void:
	if index < 0 or index >= pages.size():
		start_game()
		return

	current_page_index = index
	var p = pages[index]
	texture_rect.texture = p["texture"]
	text_label.text = p["text"]
	AudioManager.play_sfx(p["sfx"], 1.0)

	# Fade in effect
	texture_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(texture_rect, "modulate:a", 1.0, 0.4)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") or event.is_action_pressed("attack") or (event is InputEventKey and event.pressed and (event.keycode == KEY_SPACE or event.keycode == KEY_ENTER)):
		advance_page()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		start_game()

func advance_page() -> void:
	if current_page_index < pages.size() - 1:
		show_page(current_page_index + 1)
	else:
		start_game()

func start_game() -> void:
	AudioManager.play_sfx("switch", 1.2)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/level1.tscn")

func _on_next_button_pressed() -> void:
	advance_page()

func _on_skip_button_pressed() -> void:
	start_game()
