extends CanvasLayer

@onready var portrait: TextureRect = $MarginContainer/VBoxContainer/TopRow/PortraitFrame/Portrait
@onready var hero_name_label: Label = $MarginContainer/VBoxContainer/TopRow/StatsVBox/HeroNameLabel
@onready var hp_bar: TextureProgressBar = $MarginContainer/VBoxContainer/TopRow/StatsVBox/HpBar
@onready var energy_bar: TextureProgressBar = $MarginContainer/VBoxContainer/TopRow/StatsVBox/EnergyBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/TopRow/StatsVBox/HpBar/HpLabel
@onready var energy_label: Label = $MarginContainer/VBoxContainer/TopRow/StatsVBox/EnergyBar/EnergyLabel
@onready var stones_label: Label = $MarginContainer/VBoxContainer/TopRow/StonesContainer/StonesLabel
@onready var stage_label: Label = $MarginContainer/VBoxContainer/TopRow/StageLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/TopRow/ScoreLabel

var portraits = {
	"Alex": preload("res://assets/sprites/ui/portrait_alex.png"),
	"Athena": preload("res://assets/sprites/ui/portrait_athena.png"),
	"Kiri": preload("res://assets/sprites/ui/portrait_kiri.png")
}

func _ready() -> void:
	GameManager.hero_swapped.connect(_on_hero_swapped)
	GameManager.hero_health_changed.connect(_on_health_changed)
	GameManager.hero_energy_changed.connect(_on_energy_changed)
	GameManager.void_stone_destroyed.connect(_on_stones_changed)

	update_all_ui()

func update_all_ui() -> void:
	var active_name = GameManager.hero_names[GameManager.active_hero_index]
	_on_hero_swapped(active_name, GameManager.active_hero_index)
	_on_health_changed(GameManager.party_hp, GameManager.party_max_hp)
	_on_energy_changed(GameManager.party_energy, GameManager.party_max_energy)
	_on_stones_changed(GameManager.stones_remaining, GameManager.total_stones_in_level)
	if stage_label:
		stage_label.text = "STAGE %d" % GameManager.current_stage
	if score_label:
		score_label.text = "SCORE: %d" % GameManager.score

func _process(_delta: float) -> void:
	if score_label:
		score_label.text = "SCORE: %d" % GameManager.score

func _on_hero_swapped(hero_name: String, _hero_index: int) -> void:
	if hero_name_label:
		hero_name_label.text = hero_name.to_upper()
	if portrait and portraits.has(hero_name):
		portrait.texture = portraits[hero_name]

func _on_health_changed(current_hp: float, max_hp: float) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d / %d" % [int(current_hp), int(max_hp)]

func _on_energy_changed(current_energy: float, max_energy: float) -> void:
	if energy_bar:
		energy_bar.max_value = max_energy
		energy_bar.value = current_energy
	if energy_label:
		energy_label.text = "%d / %d" % [int(current_energy), int(max_energy)]

func _on_stones_changed(remaining: int, total: int) -> void:
	if stones_label:
		stones_label.text = "VOID BEACONS: %d / %d" % [remaining, total]
		if remaining == 0:
			stones_label.text = "BEACONS CLEARED! PORTAL OPEN!"
