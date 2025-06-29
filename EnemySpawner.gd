extends Node2D

@export var tower: Node2D
@export var world: Node2D
@export var enemy_spawn_timer: Timer
@export var tilemap: TileMapLayer

@export var top_left_point: Marker2D
@export var bottom_right_point: Marker2D

var day_1_spawns: Array[int] = [1, 1, 1, 1, ]

func _ready() -> void:
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)

func _on_enemy_spawn_timer_timeout():
	spawn_enemy_random_point()

func spawn_enemy_random_point():
	var random_tile_position: Vector2i = tilemap.local_to_map(get_random_spawn_point())
	world.spawn_enemy_at(random_tile_position, tower)

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
