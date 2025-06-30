extends Area2D

var damage := 5
var has_landed : bool
@export var end_position : Vector2i
@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

func _ready():
	end_position = position
	print(global_position, end_position)
	collision.visible = false
	has_landed = false
	global_position.y = end_position.y - 800
	tween_to_position(self, end_position)

func tween_to_position(target_node: Node2D, new_position: Vector2, duration := 0.5):
	var tween := create_tween()
	tween.tween_property(target_node, "position", new_position, duration)
	await get_tree().create_timer(0.5).timeout
	has_landed = true
	collision.visible = true
	_check_area()
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _check_area():
	for body in self.get_overlapping_bodies():
		if body is Enemy and has_landed:
			body.take_damage(damage)
