extends Crop


func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame = current_stage
		if current_stage == num_stages-1:
			current_state = State.MATURE
		else:
			growing_timer.start()
