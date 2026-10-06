extends Node2D
class_name LevelBase

@export var stage_number: int = 1
@export var total_stones: int = 2

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var popup_container: Node2D = $PopupContainer

var comic_popup_scene = preload("res://scenes/ui/comic_popup.tscn")

func _ready() -> void:
	AudioManager.play_bgm()
	GameManager.register_level(stage_number, total_stones)
	GameManager.comic_popup_requested.connect(_on_comic_popup_requested)
	GameManager.light_level_changed.connect(_on_light_level_changed)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over_triggered.connect(_on_game_over)

	# Initial light level
	_on_light_level_changed(0.25)

func _on_comic_popup_requested(popup_type: String, global_pos: Vector2) -> void:
	var popup = comic_popup_scene.instantiate()
	if popup_container:
		popup_container.add_child(popup)
	else:
		add_child(popup)
	popup.setup(popup_type, global_pos)

func _on_light_level_changed(light_percent: float) -> void:
	if not canvas_modulate:
		return
	# Dark void gloom shifts into warm clear light as stones shatter
	var gloom_color = Color(0.18, 0.16, 0.28, 1.0)
	var clear_color = Color(0.95, 0.95, 0.95, 1.0)
	var target_color = gloom_color.lerp(clear_color, (light_percent - 0.25) / 0.75)

	var tween = create_tween()
	tween.tween_property(canvas_modulate, "color", target_color, 1.2).set_trans(Tween.TRANS_SINE)

func _on_level_completed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/victory_screen.tscn")

func _on_game_over() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/game_over_screen.tscn")
