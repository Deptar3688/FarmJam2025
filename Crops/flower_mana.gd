extends Crop

var is_flower := true

@export var shoot_timer: Timer

func _ready() -> void:
	super()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	World.instance.mana += 5

func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame += 1
		if current_stage == num_stages-1:
			current_state = State.MATURE
		else:
			growing_timer.start()
