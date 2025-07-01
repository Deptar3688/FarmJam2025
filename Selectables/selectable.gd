class_name Selectable 
extends Area2D

@export var holding_icon : PackedScene
@onready var sprite := $Sprite2D

@export var selectable_name: String
@export var description: String

var is_currently_hovered := false
var selected := false

signal holding(object: PackedScene)
signal stop_holding
signal selected_self(selectable: Selectable)

@export var mana_cost : int

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	sprite.material.set_shader_parameter("thickness", 0)

func _process(delta):
	if is_currently_hovered and Input.is_action_just_pressed("click"):
		if !selected:
			var temp_obj = holding_icon.instantiate()
			# If it's a crop, check if the player has enough money.
			# Right now, do nothing if they don't have enough money
			if temp_obj is Crop:
				if temp_obj.gold_cost > World.instance.gold:
					_play_sfx_invalid()
					print("Not enough money. You have %s, and need %s" % [World.instance.gold, temp_obj.gold_cost])
				else:
					selected = true
					selected_self.emit(self)
					holding.emit(holding_icon)
			else:
				selected = true
				selected_self.emit(self)
				holding.emit(holding_icon)
		else:
			selected = false
			stop_holding.emit()
	_update_visual()

func _on_mouse_exited():
	is_currently_hovered = false

	World.instance.hide_tooltip()
	
func _on_mouse_entered():
	var cost: String = ""
	var value: String = ""
	var cost_string: String = ""
	var temp_obj = holding_icon.instantiate()
		# If it's a crop, check if the player has enough money.
		# Right now, do nothing if they don't have enough money
	if temp_obj is Crop:
		cost = "%sg" % temp_obj.gold_cost
		value = "%sg" % temp_obj.gold_value
		cost_string = "Buy: " + cost + " | Sell: " + value
	else:
		if mana_cost != 0:
			cost_string = "Mana Cost: " + str(mana_cost)
	World.instance.show_tooltip(selectable_name, description, cost_string)

	is_currently_hovered = true
	
func _update_visual():
	if is_currently_hovered or selected:
		$Sprite2D.material.set_shader_parameter("thickness", 2)
	else:
		$Sprite2D.material.set_shader_parameter("thickness", 0)
			

func deselect():
	selected = false
	_update_visual()

func _get_object():
	return holding_icon

func _play_sfx_invalid():
	var invalid_sfx = AudioStreamPlayer.new()
	invalid_sfx.stream = preload("res://Audio/SFX/impact-sound-effect-8-bit-retro-151796.mp3")  
	invalid_sfx.volume_db = 0.0
	add_child(invalid_sfx)
	play_sound_with_variation(invalid_sfx)
func play_sound_with_variation(player: AudioStreamPlayer, min_pitch := 0.8, max_pitch := 1.2):
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	player.pitch_scale = rng.randf_range(min_pitch, max_pitch)
	player.play()
