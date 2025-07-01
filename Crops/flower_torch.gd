extends Crop

var is_flower := true

@export var shoot_timer: Timer

@export var num_projectiles: int = 8

var fire_projectile_tscn: PackedScene = preload("res://Entities/Projectiles/FireProjectile.tscn")

func _ready() -> void:
	super ()
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _on_shoot_timer_timeout():
	if current_state == State.MATURE:
		var closest_enemy: Enemy = get_closest_enemy()
		if closest_enemy != null and position.distance_to(closest_enemy.position) < 200:
			for j in range(5):
				var angle_offset = randf_range(0, 2 * PI)
				for i in range(num_projectiles):
					var fire_projectile: Projectile = fire_projectile_tscn.instantiate()
					fire_projectile.position = position				
					var angle_to = i * 2 * PI / num_projectiles
					fire_projectile.direction = Vector2.from_angle(angle_offset + angle_to)
					add_sibling(fire_projectile)
				await get_tree().create_timer(0.05).timeout

func _on_growing_timer_timeout():
	if current_stage < num_stages:
		current_stage += 1
		current_hp = health[current_stage]
		sprite.frame += 1
		if current_stage == num_stages-1:
			current_state = State.MATURE
		else:
			growing_timer.start()
