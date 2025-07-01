class_name EnemySpawner
extends Node2D

@export var tower: Node2D
@export var world: Node2D
@export var enemy_spawn_timer: Timer
@export var tilemap: TileMapLayer

@export var top_left_point: Marker2D
@export var bottom_right_point: Marker2D

@export var wave_animation_player: AnimationPlayer

@export var freeplay_spawn_timer: Timer
@export var freeplay_total_wave_length_timer: Timer

var spawn_speed: Array[int] = [2, 1.7, 1.5, 1.2, 1, 0.7, 0.5, 0.4, 0.3, 0.2]

# func _ready() -> void:
	# enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)

func start_spawn_wave(wave: int):
	match(wave):
		1:
			wave_animation_player.play("wave_1")
		2:
			wave_animation_player.play("wave_2")
		3:
			pass
		4:
			pass
		5:
			pass
		6:
			pass
		7:
			pass
		8:
			pass
		9:
			pass
		10:
			pass
		_:
			freeplay_total_wave_length_timer.wait_time = 30 + wave * 2
			

## Returns the time left, in seconds
func get_remaining_wave_time():
	return wave_animation_player.current_animation_length - wave_animation_player.current_animation_position

func get_wave_length():
	return wave_animation_player.current_animation_length

func is_wave_active():
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
