extends Area2D

var target_position : Vector2i

func _ready():
	target_position.y = target_position.y - 3
	tween_to_position(self, target_position)

func tween_to_position(target_node: Node2D, new_position: Vector2, duration := 0.5):
	var tween := create_tween()
	tween.tween_property(target_node, "position", new_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.5).timeout
	queue_free()
