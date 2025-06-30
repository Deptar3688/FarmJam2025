class_name World
extends Node2D

static var instance: World

var gold : int = 100000:
	set(value):
		gold = value
		%GoldLabel.text = str(value)

const MAX_HEALTH : int = 100
const MAX_MANA : int = 100
var health : int = MAX_HEALTH:
	set(value):
		health = value
		%HealthLabel.text = str(value)
		
var mana : int = MAX_MANA:
	set(value):
		mana = clampi(value, 0, MAX_MANA)
		%ManaLabel.text = str(mana)

var is_in_wave := false
var wave : int = 1:
	set(value):
		wave = value
		%WaveLabel.text = "Wave: " + str(value)
var spawn_speed

@onready var night_filter := $UI/NightFilter
@onready var wave_timer := $WaveTimer 
@onready var wave_bar := %WaveBar


@onready var tilemap := $TileMaps/Layer0
@onready var placement_mask_till := $TileMaps/PlacementMaskTill
@onready var placement_mask_crops := $TileMaps/PlacementMaskCrops 
@onready var placement_mask_current := $TileMaps/PlacementMaskCurrent

# crops
@onready var CropContainer := $TileMaps/CropContainer
@onready var tilled_land_scene = preload("res://Selectables/Actions/tilled_land.tscn")
@onready var pitchfork_target_scene = preload("res://Selectables/Actions/attack_target.tscn")
@onready var pitchfork_spell_scene = preload("res://Selectables/Actions/pitchfork_spell.tscn")
@onready var scythe_target_scene = preload("res://Selectables/Actions/scythe_target.tscn")
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
	health = health
	mana = mana
	wave = wave
	#var TL_tile = Vector2i(-1,0)
	#var BL_tile = Vector2i(25,26)
	#var TR_tile = Vector2i(14,-15)
	#var TB_tile = Vector2i(39,10)
	var center_tile = Vector2i(19,5)
	
	# AStarGrid2D
	var map_size = Vector2i(41, 41)  # size of grid
	astar.region = Rect2i(Vector2i(-1, -15), map_size) # for diamond down
	astar.cell_size = Vector2(32, 16)  # isometric tile size

	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER  # disable diagonal movement
	astar.update()
	_update_walkable_tiles()

func _process(delta):
	
	## FOR SOME REASON SELECTABLES STAY HOVERED IF YOU MOVE A CURSOR OVER THEM AT A CERTAIN SPEED
	if get_global_mouse_position().x < $UI/UI.global_position.x:
		for panel in $UI/UI/GridContainer.get_children():
			panel.get_child(0).is_currently_hovered = false
			panel.get_child(0)._update_visual()
	##
	
	if !is_in_wave :
		mana = MAX_MANA
		if !night_filter.visible: night_filter.visible = true
		wave_bar.value = 30
	else:
		wave_bar.value = wave_timer.time_left
		if $EnemySpawner/EnemySpawnTimer.is_stopped() and get_tree().get_node_count_in_group("Enemy") <= 0:
			wave += 1
			is_in_wave = false
			for entity in CropContainer.get_children():
				if entity is Crop:
					entity.harvest()
				elif entity is TilledLand:
					_reset_tile(tilemap.local_to_map(entity.position / 2))
					entity.queue_free()
				else:
					entity.queue_free()
	if holding:
		holding.position = _mouse_to_tileset_position()
		
		if Input.is_action_just_pressed("click") and held_tile == pitchfork_target_scene:
			if get_global_mouse_position() > $UI/UI.global_position:
				print("invalid placement")
			else:
				if mana >= 5:
					mana -= 5
					for i in range(3):
						await get_tree().create_timer(0.04).timeout
						_cast_spell(holding.position)
		elif Input.is_action_just_pressed("click") and held_tile == scythe_target_scene:
			for entity in CropContainer.get_children():
				# Remove the tilled land at the scythe position
				if entity is TilledLand and tilemap.local_to_map(entity.position) == tilemap.local_to_map(holding.position):
					entity.queue_free()
			_harvest_crop(holding.position)
		elif Input.is_action_just_pressed("click") and is_tile_placeable(holding.position):
			_place_tile()
		elif Input.is_action_just_pressed("click") and !is_tile_placeable(holding.position):
			print("invalid placement")
	
# harvest
func _harvest_crop(target_position:Vector2):
	for crop in CropContainer.get_children():
		if crop is Crop:
			var tile_coords = tilemap.local_to_map(crop.global_position)
			if crop.position == target_position and mana >= 5:
				crop.harvest()

# spellcast
func _cast_spell(location : Vector2i):
	var tile_size = tilemap.tile_set.tile_size
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var offset = Vector2i(
		rng.randf_range(-tile_size.x, tile_size.x),
		rng.randf_range(-tile_size.y, tile_size.y)
	)
	var random_position_on_tile = location + offset
	var spell = pitchfork_spell_scene.instantiate()
	spell.global_position = random_position_on_tile
	entity_container.add_child(spell)

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
		# Make the tile plantable again if the crop has died from enemies
		new_crop.has_died.connect(_reenable_tile.bind(tile_coords), CONNECT_ONE_SHOT)
		# Reset the tile the crop is on if its being harvested
		new_crop.has_been_harvested.connect(_reset_tile.bind(tile_coords), CONNECT_ONE_SHOT)
	
	if held_tile != tilled_land_scene:
		new_crop._start_growing()
		placement_mask_crops.set_cell(tile_coords, 1, Vector2i(0,1))
	elif held_tile == tilled_land_scene and mana >= 5:
		mana -= 5
		placement_mask_till.set_cell(tile_coords, 1, Vector2i(0,1))
		placement_mask_crops.set_cell(tile_coords, 0, Vector2i(0,1))

func _reenable_tile(tile_coords: Vector2i):
	placement_mask_crops.set_cell(tile_coords, 0, Vector2i(0,1))

func _reset_tile(tile_coords: Vector2i):
	placement_mask_till.set_cell(tile_coords, 0, Vector2i(0,1))
	placement_mask_crops.set_cell(tile_coords, 1, Vector2i(0,1))

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
	
	if held_tile == pitchfork_target_scene or held_tile == scythe_target_scene:
		placement_mask_current.visible = false
	elif held_tile != tilled_land_scene:
		placement_mask_current = placement_mask_crops
		placement_mask_current.visible = true
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

# scythe selectable
func _on_scythe_holding(object):
	_hold_object(object)
func _on_scythe_stop_holding():
	_stop_holding()

# spell selectable
func _on_spell_holding(object):
	_hold_object(object)
func _on_spell_stop_holding():
	_stop_holding()
	
# Switch holding
func _on_grid_container_switch_holding(object):
	_switch_holding()
func _switch_holding():
	placement_mask_current.visible = false
	_stop_holding()

func show_tooltip(selectable_name: String, description: String, cost: String):
	%ToolTipContainer.visible = true
	%SelectableNameLabel.text = selectable_name
	%SelectableDescriptionLabel.text = description
	%SelectableCostLabel.text = cost

func hide_tooltip():
	%ToolTipContainer.visible = false

func _on_cancel_selection_button_pressed():
	if holding:
		_stop_holding()
		$UI/UI/GridContainer._on_stop_holding()
		for panel in $UI/UI/GridContainer.get_children():
			panel.get_child(0).deselect()

func _on_start_pause_button_pressed():
	if night_filter.visible: night_filter.visible = false
	is_in_wave = true
	if wave <= 10:
		spawn_speed = $EnemySpawner.spawn_speed[wave-1]
	else:
		spawn_speed = $EnemySpawner.spawn_speed[9]
	$EnemySpawner/EnemySpawnTimer.start(spawn_speed)
	if wave_timer.is_stopped():
		wave_timer.start()
	
func _on_mana_regen_timeout():
	if mana < MAX_MANA:
		mana += 1

func _on_wave_timer_timeout():
	$EnemySpawner/EnemySpawnTimer.stop()
	
