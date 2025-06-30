class_name Tower
extends Area2D

var health : int
var current_hp : int

@onready var sprite := $Sprite2D
@onready var attack_cooldown := $AttackCooldown
var can_attack : bool

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 100
	current_hp = health


func _on_attack_cooldown_timeout():
	can_attack = true

func take_damage(damage: int):
	print(current_hp)
	current_hp -= damage
	World.instance.health = current_hp
	if current_hp <= 50 and current_hp > 0:
		sprite.frame = 1
		
	if current_hp <= 0:
		sprite.frame = 2
		game_over.emit()
