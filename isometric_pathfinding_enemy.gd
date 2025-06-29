class_name Enemy
extends CharacterBody2D

@export var original_target: Node2D
@export var tilemap: TileMapLayer

var target : Node2D
var path : PackedVector2Array
var path_index := 0
var speed := 1.0
var astar: AStarGrid2D
var direction

var _hp: float = 10

@onready var sprite := $EntityContainer/Sprite2D

var is_attacking : bool
@onready var attack_range := $AttackRange
@onready var attack_cooldown := $AttackSpeed
@onready var fireball_scene := preload("res://Entities/fireball.tscn")
@onready var fireball_container := $EntityContainer 

func _ready():
	target = original_target
	path = generate_path_to_target(target)
	path_index = 0
	
func set_astar_data(_astar: AStarGrid2D, _tilemaplayer: TileMapLayer):
	astar = _astar
	tilemap = _tilemaplayer

func generate_path_to_target(target_local):
	var start = tilemap.local_to_map(tilemap.to_local(global_position))
	var target_position = tilemap.local_to_map(tilemap.to_local(target_local.global_position))
	return astar.get_id_path(start, target_position)
	
func _physics_process(delta):
	
	if path_index >= path.size():
		return
	
	var tile = path[path_index]
	var target_pos = tilemap.to_global(tilemap.map_to_local(tile))
	direction = (target_pos - global_position)
	
	# update sprite
	if direction.x < 0 and direction.y < 0:
		sprite.frame = 0
	elif direction.x > 0 and direction.y < 0:
		sprite.frame = 1
	elif direction.x > 0 and direction.y > 0:
		sprite.frame = 2
	elif direction.x < 0 and direction.y > 0:
		sprite.frame = 3
	
	if direction.length() < 2:
		path_index += 1
	else:
		position += direction.normalized() * speed
	
	#fireball.position = sprite.position + direction.normalized() * 5
	
	if is_attacking:
		speed = 0
	
		if !attack_range.has_overlapping_areas():
			is_attacking = false
			attack_cooldown.stop()
			path = generate_path_to_target(original_target)
		
	
	#for area in attack_range.get_overlapping_areas():
		#attack_cooldown.autostart = false
		#speed = 1.0

func _on_aggro_range_area_entered(area):
	if area is Crop: 
		if area.current_state != 0: # if placed
			var new_path = generate_path_to_target(area)
			if generate_path_to_target(target).size() > new_path.size():
				target = area
				path = new_path
				path_index = 1
			
	else:
		print(area.name)

func _on_attack_range_area_entered(area):
	if area is Crop:
		if area.current_state != 0:
			is_attacking = true
			attack_cooldown.start()
	else:
		is_attacking = true
		attack_cooldown.start()
func _on_attack_speed_timeout():
	var fireball2 = fireball_scene.instantiate()
	fireball2.target_position = to_local(target.global_position)
	fireball2.position = sprite.position + direction.normalized() * 5
	fireball_container.add_child(fireball2)

func take_damage(damage: int):
	_hp -= damage
	
	shake_sprite()
	#damage flash
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.01)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)
	
	if _hp <= 0:
		queue_free()
	
func shake_sprite(intensity := 1.5, duration := 0.2, shakes := 3):
	var tween := create_tween()
	var original_position = sprite.position
	
	for i in shakes:
		var offset = Vector2(randf_range(-intensity, intensity), 0)
		tween.tween_property(sprite, "position", original_position + offset, duration / (shakes * 2))
		tween.tween_property(sprite, "position", original_position, duration / (shakes * 2))
