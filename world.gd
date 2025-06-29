class_name World
extends Node2D

static var instance: World

var gold : int = 100000:
	set(value):
		gold = value
		%GoldLabel.text = str(value)


@onready var tilemap := $TileMaps/Layer0
@onready var placement_mask_till := $TileMaps/PlacementMaskTill
@onready var placement_mask_crops := $TileMaps/PlacementMaskCrops 
@onready var placement_mask_current := $TileMaps/PlacementMaskCurrent

# crops
@onready var CropContainer := $TileMaps/CropContainer
@onready var wheat_scene = preload("res://Crops/crop_wheat.tscn")
@onready var tilled_land_scene = preload("res://Selectables/Actions/tilled_land.tscn")

# placement indicators
@onready var HoldingContainer := $UI/HoldingContainer
var holding : Node2D
var held_tile : PackedScene

# pathfinding
@onready var entity_container := $EntityContainer
var astar := AStarGrid2D.new()
@onready var tower := $EntityContainer/Tower

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	%ToolTipContainer.visible = false
	gold = gold
	#var TL_tile = Vector2i(-1,0)
	#var BL_tile = Vector2i(25,26)
	#var TR_tile = Vector2i(14,-15)
	#var TB_tile = Vector2i(39,10)
	var center_tile = Vector2i(19,5)
	
	# AStarGrid2D
	var map_size = Vector2i(41, 41)  # size of your grid
	astar.region = Rect2i(Vector2i(-1, -15), map_size) # for diamond down
	astar.cell_size = Vector2(32, 16)  # isometric tile size

	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER  # disable diagonal movement
	astar.update()
	_update_walkable_tiles()
	#spawn_enemy_at(Vector2i(15,-5), tower)
	#spawn_enemy_at(Vector2i(31,12), tower)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if holding:
		holding.position = _mouse_to_tileset_position()
		
		if Input.is_action_just_pressed("click") and is_tile_placeable(holding.position):
			_place_tile()
		elif Input.is_action_just_pressed("click") and !is_tile_placeable(holding.position):
			print("invalid placement")
	
# Navigation
func _update_walkable_tiles():
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var tile_pos = Vector2i(x, y)
			var tile_id = tilemap.get_cell_source_id(tile_pos)
			
			var walkable = true
			# Block if it's a crop or unwalkable terrain
			if tile_id in [3,5]:
				walkable = false
			
			#print("(",x,",",y,"):",tile_id,walkable)
			if astar.is_in_bounds(tile_pos.x, tile_pos.y):
				astar.set_point_solid(tile_pos, !walkable)
	
	astar.update()

func spawn_enemy_at(tile_pos: Vector2i, target: Node2D):
	var enemy = preload("res://Entities/witch_enemy.tscn").instantiate()
	enemy.position = tilemap.to_global(tilemap.map_to_local(tile_pos))
	enemy.set_astar_data(astar, tilemap)
	enemy.original_target = target
	entity_container.add_child(enemy)
	enemy.scale = Vector2i(2,2)


func _place_tile():
	var new_crop = held_tile.instantiate()
	var tile_pos = _mouse_to_tileset_position()

	# update placement mask
	var mouse_pos = get_global_mouse_position()
	var local_pos = placement_mask_current.to_local(mouse_pos)
	var tile_coords = placement_mask_current.local_to_map(local_pos)

	new_crop.position = tile_pos
	CropContainer.add_child(new_crop)
	if new_crop is Crop:
		new_crop.has_died.connect(_reenable_tile.bind(tile_coords), CONNECT_ONE_SHOT)
	
	if held_tile != tilled_land_scene:
		new_crop._start_growing()
		placement_mask_crops.set_cell(tile_coords, 1, Vector2i(0,1))
	elif held_tile == tilled_land_scene:
		placement_mask_till.set_cell(tile_coords, 1, Vector2i(0,1))
		placement_mask_crops.set_cell(tile_coords, 0, Vector2i(0,1))

func _reenable_tile(tile_coords: Vector2i):
	print(tile_coords)
	placement_mask_crops.set_cell(tile_coords, 0, Vector2i(0,1))

# checks PlacementMask to see if area is valid
func is_tile_placeable(tile_pos: Vector2i):
	var mouse_pos = get_global_mouse_position()
	var local_pos = placement_mask_current.to_local(mouse_pos)
	var tile_coords = placement_mask_current.local_to_map(local_pos)
	var tile_id = placement_mask_current.get_cell_source_id(tile_coords)
	#print(tile_id)
	return tile_id == 0 # true if valid


func _mouse_to_tileset_position():
	var mouse_pos = get_global_mouse_position()
	var local_mouse_pos = tilemap.to_local(mouse_pos)  # converts global to TileMap-local
	var tile_coords = tilemap.local_to_map(local_mouse_pos)  # converts local pos to tile coords
	var world_pos = tilemap.to_global(tilemap.map_to_local(tile_coords))  # snap to tile center
	return world_pos

#func _update_placement_mask():


func _hold_object(object):
	held_tile = object
	holding = object.instantiate()
	holding.position = _mouse_to_tileset_position()
	HoldingContainer.add_child(holding)
	if held_tile != tilled_land_scene:
		placement_mask_current = placement_mask_crops
	else:
		placement_mask_current = placement_mask_till
		
	placement_mask_current.visible = true
	
func _stop_holding():
	held_tile = null
	holding.queue_free()
	holding = null
	placement_mask_current.visible = false

# Wheat selectable 
func _on_wheat_seed_bag_holding(object):
	_hold_object(object)
func _on_wheat_seed_bag_stop_holding():
	_stop_holding()

# Grape selectable
func _on_grape_seed_bag_holding(object):
	_hold_object(object)
func _on_grape_seed_bag_stop_holding():
	_stop_holding()

# Tomato selectable
func _on_tomato_seed_bag_holding(object):
	_hold_object(object)
func _on_tomato_seed_bag_stop_holding():
	_stop_holding()

# Pumpkin selectable 
func _on_pumpkin_seed_bag_holding(object):
	_hold_object(object)
func _on_pumpkin_seed_bag_stop_holding():
	_stop_holding()

# Mana selectable 
func _on_mana_seed_bag_holding(object):
	_hold_object(object)
func _on_mana_seed_bag_stop_holding():
	_stop_holding()

# Rose selectable 
func _on_rose_seed_bag_holding(object):
	_hold_object(object)
func _on_rose_seed_bag_stop_holding():
	_stop_holding()
	
# Torch selectable
func _on_torch_seed_bag_holding(object):
	_hold_object(object)
func _on_torch_seed_bag_stop_holding():
	_stop_holding()
 
# hoe selectable
func _on_hoe_holding(object):
	_hold_object(object)
func _on_hoe_stop_holding():
	_stop_holding()

# Switch holding
func _on_grid_container_switch_holding(object):
	_switch_holding(object.holding_icon)

func _switch_holding(object):
	_stop_holding()

func show_tooltip(selectable_name: String, description: String, cost: String):
	%ToolTipContainer.visible = true
	%SelectableNameLabel.text = selectable_name
	%SelectableDescriptionLabel.text = description
	%SelectableCostLabel.text = cost

func hide_tooltip():
	%ToolTipContainer.visible = false
