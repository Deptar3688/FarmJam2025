class_name Projectile
extends Area2D

@export var rotation_speed: float = 2 * PI
@export var speed: float = 5
@export var damage: int = 3
@export var pierce: int = 1

@export var sprite: Sprite2D
@export var lifetime_timer: Timer

var direction: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	lifetime_timer.timeout.connect(queue_free)

func _process(delta: float) -> void:
	sprite.rotation += delta * rotation_speed
	position += direction.normalized() * delta * speed

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()
