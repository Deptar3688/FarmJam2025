class_name EnemySpawner
extends Node2D

@export var tower: Node2D
@export var world: Node2D
@export var enemy_spawn_timer: Timer
@export var tilemap: TileMapLayer

@export var top_left_point: Marker2D
@export var bottom_right_point: Marker2D

@export var wave_animation_player: AnimationPlayer

var is_freeplay_enabled: bool = false
@export var freeplay_spawn_timer: Timer
@export var freeplay_total_wave_length_timer: Timer

func _ready() -> void:
	freeplay_spawn_timer.timeout.connect(freeplay_spawn)
	freeplay_total_wave_length_timer.timeout.connect(func(): freeplay_spawn_timer.stop())

func start_spawn_wave(wave: int):
	match (wave):
		1:
			wave_animation_player.play("wave_1")
		2:
			wave_animation_player.play("wave_2")
		3:
			wave_animation_player.play("wave_3")
		4:
			wave_animation_player.play("wave_4")
		5:
			wave_animation_player.play("wave_5")
		6:
			wave_animation_player.play("wave_6")
		7:
			wave_animation_player.play("wave_7")
		8:
			wave_animation_player.play("wave_8")
		9:
			wave_animation_player.play("wave_9")
		10:
			wave_animation_player.play("wave_10")
		_:
			is_freeplay_enabled = true
			freeplay_total_wave_length_timer.wait_time = 30 + wave * 2
			freeplay_total_wave_length_timer.start()
			freeplay_spawn_timer.start()

## Returns the time left, in seconds
func get_remaining_wave_time():
	if is_freeplay_enabled:
		return freeplay_total_wave_length_timer.time_left
	return wave_animation_player.current_animation_length - wave_animation_player.current_animation_position

func get_wave_length():
	if is_freeplay_enabled:
		return freeplay_total_wave_length_timer.wait_time
	return wave_animation_player.current_animation_length

func is_wave_active():
	if is_freeplay_enabled:
		return !freeplay_total_wave_length_timer.is_stopped()
	return wave_animation_player.is_playing()

func spawn_enemy_random_point(amount: int, enemy_type: Enemy.EnemyType = Enemy.EnemyType.NORMAL):
	for i in amount:
		var random_tile_position: Vector2i = tilemap.local_to_map(get_random_spawn_point())
		world.spawn_enemy_at(random_tile_position, tower, enemy_type)

# Get random point along the perimeter of the square, defined by top left and bottom right points
func get_random_spawn_point() -> Vector2:
	match randi_range(0, 3):
		0:
			return Vector2(randf_range(top_left_point.position.x, bottom_right_point.position.x), top_left_point.position.y) / 2
		1:
			return Vector2(randf_range(top_left_point.position.x, bottom_right_point.position.x), bottom_right_point.position.y) / 2
		2:
			return Vector2(top_left_point.position.x, randf_range(top_left_point.position.y, bottom_right_point.position.y)) / 2
		3:
			return Vector2(bottom_right_point.position.x, randf_range(top_left_point.position.y, bottom_right_point.position.y)) / 2
		_:
			return Vector2.ZERO

func freeplay_spawn():
	var wave = World.instance.wave
	var variant_chance = clampf(0.2 + wave * 0.02, 0.2, 0.7)
	if randf() < variant_chance:
		var amount: int = randi_range(1, 1 + wave / 15)
		match randi_range(0, 2):
			0: # Tanky version
				spawn_enemy_random_point(amount, Enemy.EnemyType.TANKY)
			1: # Fast version
				spawn_enemy_random_point(amount, Enemy.EnemyType.SPEEDY)
			2: # Ranged version
				spawn_enemy_random_point(amount, Enemy.EnemyType.RANGED)
			_:
				pass
	else:
		var amount: int = randi_range(1, 1 + wave / 16)
		spawn_enemy_random_point(amount)
