class_name Tower
extends Area2D

var health : int
var current_hp : int

@onready var sprite := $Sprite2D
@onready var attack_cooldown := $AttackCooldown
var can_attack : bool
var original_position 

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready():
	health = 100
	current_hp = health
	original_position = sprite.position


func _on_attack_cooldown_timeout():
	can_attack = true

func take_damage(damage: int):
	shake_sprite()
	current_hp -= damage
	World.instance.health = current_hp
	if current_hp <= 50 and current_hp > 0:
		sprite.frame = 1
		
	if current_hp <= 0:
		sprite.frame = 2
		game_over.emit()

func shake_sprite(intensity := 2, duration := 0.1, shakes := 3):
	var tween := create_tween()
	
	for i in shakes:
		var offset = Vector2(randf_range(-intensity, intensity), 0)
		tween.tween_property(sprite, "position", original_position + offset, duration / (shakes * 2))
		tween.tween_property(sprite, "position", original_position, duration / (shakes * 2))
	sprite.position = original_position
