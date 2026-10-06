@tool
extends StaticBody2D
class_name LevelPlatform

@export var size: Vector2 = Vector2(160, 32):
	set(val):
		size = val
		update_platform()

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var nine_patch: NinePatchRect = $NinePatchRect

func _ready() -> void:
	add_to_group("terrain")
	update_platform()

func update_platform() -> void:
	if not col_shape or not nine_patch:
		return
	nine_patch.size = size
	nine_patch.position = -size / 2.0

	var rect := RectangleShape2D.new()
	rect.size = size
	col_shape.shape = rect
