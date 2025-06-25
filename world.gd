extends Node2D

@onready var tilemap := $TileMaps/Layer0
@onready var tilemapplayer := $TileMaps/Layer1
@onready var CropContainer := $TileMaps/CropContainer
@onready var wheat_scene = preload("res://Crops/crop_wheat.tscn")
@onready var placement_mask := $TileMaps/PlacementMask
@onready var HoldingContainer := $UI/HoldingContainer
var holding : Node2D
var held_tile : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var TL_tile = Vector2i(-1,0)
	var BL_tile = Vector2i(25,26)
	var TR_tile = Vector2i(14,-15)
	var TB_tile = Vector2i(39,10)
	var center_tile = Vector2i(19,5)
	tilemapplayer.set_cell(center_tile, 3, Vector2i(0,0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if holding:
		holding.position = _mouse_to_tileset_position()
		
		if Input.is_action_just_pressed("click") and is_tile_placeable(holding.position):
			var new_crop = held_tile.instantiate()
			var tile_pos = _mouse_to_tileset_position()
			new_crop.position = tile_pos
			CropContainer.add_child(new_crop)
		elif Input.is_action_just_pressed("click") and !is_tile_placeable(holding.position):
			print("invalid placement")

# checks PlacementMask to see if area is valid
func is_tile_placeable(tile_pos: Vector2i):
	var mouse_pos = get_global_mouse_position()
	var local_pos = placement_mask.to_local(mouse_pos)
	var tile_coords = placement_mask.local_to_map(local_pos)
	var tile_id = placement_mask.get_cell_source_id(tile_coords)
	print(tile_id)
	return tile_id == 0 # true if valid


func _mouse_to_tileset_position():
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = tilemap.to_local(mouse_pos)  # converts global to TileMap-local
	var tile_coords = tilemap.local_to_map(local_mouse_pos)  # converts local pos to tile coords
	var world_pos = tilemap.to_global(tilemap.map_to_local(tile_coords))  # snap to tile center
	return world_pos

func _hold_object(object):
	held_tile = object
	holding = object.instantiate()
	holding.position = _mouse_to_tileset_position()
	HoldingContainer.add_child(holding)
	placement_mask.visible = true

func _stop_holding():
	held_tile = null
	holding.queue_free()
	holding = null
	placement_mask.visible = false

func _switch_holding(object):
	_stop_holding()

func _on_seed_bag_holding(object):
	_hold_object(object)

func _on_hoe_holding(object):
	_hold_object(object)

func _on_seed_bag_stop_holding():
	_stop_holding()

func _on_hoe_stop_holding():
	_stop_holding()

func _on_grid_container_switch_holding(object):
	_switch_holding(object.holding_icon)
