extends Area2D

@export var speed: float = 400.0
@export var damage: float = 45.0
@export var life_time: float = 0.9
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()
	var timer = get_tree().create_timer(life_time)
	timer.timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		GameManager.request_comic_popup("BOOM", global_position)
		queue_free()
	elif body.is_in_group("terrain"):
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(damage, global_position)
		GameManager.request_comic_popup("BOOM", global_position)
		queue_free()
