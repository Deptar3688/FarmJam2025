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
