extends AnimatableBody2D
class_name MovingPlatform

@export var move_offset: Vector2 = Vector2(140, 0)
@export var move_duration: float = 3.0
@export var platform_size: Vector2 = Vector2(110, 24)

@onready var nine_patch: NinePatchRect = $NinePatchRect
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var start_pos: Vector2
var tween: Tween

func _ready() -> void:
	add_to_group("terrain")
	start_pos = position
	nine_patch.size = platform_size
	nine_patch.position = -platform_size / 2.0
	var rect = RectangleShape2D.new()
	rect.size = platform_size
	col_shape.shape = rect

	start_movement()

func start_movement() -> void:
	tween = create_tween().set_loops()
	tween.tween_property(self, "position", start_pos + move_offset, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
