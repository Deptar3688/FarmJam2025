class_name Crop
extends Node2D

@export var crop_name: String
@export var num_stages: int
@export var sprite: Sprite2D
@export var growing_timer: Timer
@export var health: Array[int] # changes depending on growth stage
enum State {PLACING, GROWING, MATURE, ENCHANCED}
var is_placed : bool
var is_enchanced : bool
var current_state

var current_hp
var current_stage

@export var attack_dmg: int
@export var attack_spd: int
@export var attack_range: int

func _ready():
	current_state = State.PLACING
	is_placed = false
	is_enchanced = false
	current_stage = 0
	current_hp = health[0]


func _start_growing():
	is_placed = true
	current_state = State.GROWING
	growing_timer.start()

func get_closest_enemy():
	var closest_dist: float = INF
	var closest_enemy: Enemy
	for enemy: Enemy in get_tree().get_nodes_in_group("Enemy"):
		if position.distance_to(enemy.position) < closest_dist:
			closest_dist = position.distance_to(enemy.position)
			closest_enemy = enemy
	return closest_enemy
