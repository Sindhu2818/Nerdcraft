extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

func _ready() -> void:
	AudioManager.play_sfx("shatter", 0.8)

func _on_retry_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	var scene_path = "res://scenes/levels/level%d.tscn" % GameManager.current_stage
	get_tree().call_deferred("change_scene_to_file", scene_path)

func _on_title_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	GameManager.current_stage = 1
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/title_screen.tscn")
