extends Area2D

@export var speed: float = 280.0
@export var damage: float = 15.0
@export var life_time: float = 2.0
var direction: Vector2 = Vector2.LEFT

func _ready() -> void:
	rotation = direction.angle()
	var timer = get_tree().create_timer(life_time)
	timer.timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.damage_hero(damage, global_position)
		queue_free()
	elif body.is_in_group("terrain"):
		queue_free()
