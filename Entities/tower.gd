class_name Tower
extends Area2D

var health : int
var mana : int
var current_hp : int

@onready var attack_cooldown := $AttackCooldown
var can_attack : bool
# Called when the node enters the scene tree for the first time.
func _ready():
	health = 200
	mana = 100
	current_hp = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_hp == 0:
		die()

func die():
	queue_free()

func _on_attack_cooldown_timeout():
	can_attack = true
