extends Crop

@export var shoot_timer: Timer

func _ready() -> void:
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	pass

func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame += 1
		if current_stage == num_stages-1:
			current_state = State.MATURE
		else:
			growing_timer.start()
