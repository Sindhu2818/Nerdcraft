extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var textures = {
	"SHATTER": preload("res://assets/sprites/vfx/comic_shatter.png"),
	"BOOM": preload("res://assets/sprites/vfx/comic_boom.png"),
	"WHOOSH": preload("res://assets/sprites/vfx/comic_whoosh.png"),
	"CRACK": preload("res://assets/sprites/vfx/comic_crack.png"),
	"LIGHT": preload("res://assets/sprites/vfx/comic_light.png")
}

func setup(popup_type: String, target_global_pos: Vector2) -> void:
	global_position = target_global_pos + Vector2(randf_range(-15, 15), randf_range(-25, -10))
	if textures.has(popup_type):
		sprite.texture = textures[popup_type]
	else:
		sprite.texture = textures["BOOM"]

	scale = Vector2(0.2, 0.2)
	modulate = Color(1, 1, 1, 1)

	# Comic pop bounce animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
	tween.parallel().tween_property(self, "position:y", position.y - 30.0, 0.45).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_callback(queue_free)
