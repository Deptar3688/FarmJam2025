extends Area2D

var damage := 6
var has_landed : bool
@export var end_position : Vector2i
@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D

func _ready():
	var rng = RandomNumberGenerator.new()

	sprite.frame = rng.randi_range(0,1)
	end_position = position
	collision.visible = false
	has_landed = false
	global_position.y = end_position.y - 800
	tween_to_position(self, end_position)

func tween_to_position(target_node: Node2D, new_position: Vector2, duration := 0.5):
	var tween := create_tween()
	tween.tween_property(target_node, "position", new_position, duration)
	await get_tree().create_timer(0.5).timeout
	has_landed = true
	collision.visible = true
	_play_sfx_impact()
	_check_area()
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _check_area():
	for body in self.get_overlapping_bodies():
		if body is Enemy and has_landed:
			body.take_damage(damage)

func _play_sfx_impact():
	var fire_sfx = AudioStreamPlayer.new()
	fire_sfx.stream = preload("res://Audio/SFX/impact-sound-effect-8-bit-retro-151796.mp3")  
	fire_sfx.volume_db = 0.0
	add_child(fire_sfx)
	play_sound_with_variation(fire_sfx)

func play_sound_with_variation(player: AudioStreamPlayer, min_pitch := 0.8, max_pitch := 1.2):
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	player.pitch_scale = rng.randf_range(min_pitch, max_pitch)
	player.play()
	player.finished.connect(player.queue_free)
