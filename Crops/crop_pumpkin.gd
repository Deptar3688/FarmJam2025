extends Crop

@export var shoot_timer: Timer
var pumpkin_projectile_tscn: PackedScene = preload("res://Entities/Projectiles/PumpkinProjectile.tscn")

func _ready() -> void:
	super()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	if current_state == State.MATURE:
		var pumpkin_projectile: Projectile = pumpkin_projectile_tscn.instantiate()
		pumpkin_projectile.position = position
		var closest_enemy: Enemy = get_closest_enemy()
		if closest_enemy != null:
			var angle_offset = randf_range( -PI / 12, PI / 12)
			var angle_to = position.angle_to_point(closest_enemy.position)
			pumpkin_projectile.direction = Vector2.from_angle(angle_offset + angle_to)
			pumpkin_projectile.speed *= randf_range(0.9, 1.1)
		add_sibling(pumpkin_projectile)

func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame += 1
		if current_stage == num_stages-1:
			current_state = State.MATURE
			growing_timer.stop()
		else:
			growing_timer.start()
