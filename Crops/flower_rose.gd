extends Crop

@export var shoot_timer: Timer
var thorn_projectile_tscn: PackedScene = preload("res://Entities/Projectiles/ThornProjectile.tscn")

func _ready() -> void:
	super ()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	if current_state == State.MATURE:
		var closest_enemy: Enemy = get_closest_enemy()
		if closest_enemy != null and position.distance_to(closest_enemy.position) < 100:
			var thorn_projectile: Projectile = thorn_projectile_tscn.instantiate()
			thorn_projectile.position = position
			var angle_offset = randf_range(-PI / 6, PI / 6)
			var angle_to = position.angle_to_point(closest_enemy.position)
			thorn_projectile.direction = Vector2.from_angle(angle_offset + angle_to)
			thorn_projectile.speed *= randf_range(0.6, 1.4)
			add_sibling(thorn_projectile)

var is_flower := true
func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame += 1
		if current_stage == num_stages-1:
			current_state = State.MATURE
		else:
			growing_timer.start()
