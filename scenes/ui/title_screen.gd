extends Control

@onready var controls_panel: PanelContainer = $ControlsModal

func _ready() -> void:
	AudioManager.play_bgm()
	if controls_panel:
		controls_panel.visible = false

func _on_start_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/comic_prologue.tscn")

func _on_stage1_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	get_tree().call_deferred("change_scene_to_file", "res://scenes/levels/level1.tscn")

func _on_controls_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	if controls_panel:
		controls_panel.visible = true

func _on_close_controls_pressed() -> void:
	AudioManager.play_sfx("switch", 0.9)
	if controls_panel:
		controls_panel.visible = false
