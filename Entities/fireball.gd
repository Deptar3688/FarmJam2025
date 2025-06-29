class_name Fireball
extends Area2D

var target_position : Vector2i

var node_to_damage: Node2D

func _ready():
	target_position.y = target_position.y - 3
	tween_to_position(self, target_position)

func tween_to_position(target_node: Node2D, new_position: Vector2, duration := 0.5):
	var tween := create_tween()
	tween.tween_property(target_node, "position", new_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(node_to_damage):
		if node_to_damage is Crop:
			node_to_damage.take_damage(1)
	queue_free()
