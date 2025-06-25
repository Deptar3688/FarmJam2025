extends Node

# Reference to the tilemap
@export var tilemap: TileMapLayer
@export var crop_container: Node2D

# Dictionary to track tile occupancy
var occupied_tiles: Dictionary = {}

func is_tile_occupied(tile_pos: Vector2i) -> bool:
	return occupied_tiles.has(tile_pos)

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(world_pos))

func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(tile_pos))

func place_crop(crop_scene: PackedScene, world_pos: Vector2) -> bool:
	var tile_pos = world_to_tile(world_pos)

	if is_tile_occupied(tile_pos):
		print("Tile occupied!")
		return false

	var crop = crop_scene.instantiate()
	crop.position = tile_to_world(tile_pos)
	crop_container.add_child(crop)
	occupied_tiles[tile_pos] = crop
	return true

func remove_crop_at(world_pos: Vector2):
	var tile_pos = world_to_tile(world_pos)

	if not is_tile_occupied(tile_pos):
		return

	var crop = occupied_tiles[tile_pos]
	crop.queue_free()
	occupied_tiles.erase(tile_pos)
