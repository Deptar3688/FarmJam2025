extends Control

@onready var witches := $Witches
@onready var title := $RichTextLabel 
@onready var play := $VBoxContainer

var witches_original_position : Vector2
var title_original_position : Vector2 
var play_original_position : Vector2

func _ready():
	witches_original_position = witches.position
	title_original_position = title.position
	play_original_position = play.position
	witches.position.y = witches.position.y + 600
	title.position.y = title.position.y - 500
	play.position.y = title.position.y
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate", Color.TRANSPARENT, 1)
	await get_tree().create_timer(1.5).timeout
	tween_to_position(title, title_original_position)
	tween_to_position(play, play_original_position)
	await get_tree().create_timer(1).timeout
	
func _on_play_button_pressed():
	tween_to_position(witches, witches_original_position)
	await get_tree().create_timer(0.8).timeout
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate", Color.BLACK, 1)
	fade_out_music($AudioStreamPlayer, 0.8)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://world.tscn")
	

func tween_to_position(node, new_position: Vector2, duration := 0.8):
	var tween := create_tween()
	tween.tween_property(node, "position", new_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func fade_out_music(player: AudioStreamPlayer, duration := 0.8):
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(player, "stop"))
