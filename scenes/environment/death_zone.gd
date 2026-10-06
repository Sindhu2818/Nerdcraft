extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.damage_hero(35.0, global_position)
		if body is CharacterBody2D:
			body.velocity = Vector2.ZERO
			body.global_position = Vector2(100.0, 160.0)
	elif body.is_in_group("enemies"):
		body.queue_free()
