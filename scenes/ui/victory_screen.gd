extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
@onready var next_button: Button = $CenterContainer/VBoxContainer/NextButton

func _ready() -> void:
	AudioManager.play_sfx("victory", 1.0)
	score_label.text = "FINAL SCORE: %d" % GameManager.score

	if GameManager.current_stage >= GameManager.MAX_STAGES:
		title_label.text = "THE LIGHT IS RESTORED!\nYOU SAVED THE LAST PAGE!"
		next_button.text = "PLAY AGAIN (TITLE)"
	else:
		title_label.text = "STAGE %d CLEARED!" % GameManager.current_stage
		next_button.text = "PROCEED TO STAGE %d" % (GameManager.current_stage + 1)

func _on_next_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	if GameManager.current_stage >= GameManager.MAX_STAGES:
		GameManager.current_stage = 1
		get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/title_screen.tscn")
	else:
		var next_stage_num = GameManager.current_stage + 1
		var next_scene_path = "res://scenes/levels/level%d.tscn" % next_stage_num
		get_tree().call_deferred("change_scene_to_file", next_scene_path)

func _on_menu_button_pressed() -> void:
	AudioManager.play_sfx("switch", 1.0)
	GameManager.current_stage = 1
	get_tree().call_deferred("change_scene_to_file", "res://scenes/ui/title_screen.tscn")
