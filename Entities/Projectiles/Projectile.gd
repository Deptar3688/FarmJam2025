class_name Projectile
extends Area2D

@export var rotation_speed: float = 2 * PI
@export var speed: float = 5
@export var damage: int = 3
@export var pierce: int = 1
@export var sprite_faces_direction: bool = false
@export var slows_down: bool = false

@export var sprite: Sprite2D
@export var lifetime_timer: Timer

var direction: Vector2

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	lifetime_timer.timeout.connect(queue_free)
	if slows_down:
		create_tween().tween_property(self, "speed", 0, lifetime_timer.wait_time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _process(delta: float) -> void:
	sprite.rotation += delta * rotation_speed
	position += direction.normalized() * delta * speed
	if sprite_faces_direction:
		sprite.rotation = position.angle_to(direction) + 3 * PI / 4

func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()
