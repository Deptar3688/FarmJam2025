extends Control


func _ready():
	$VBoxContainer/RichTextLabel2.text = "You reached wave: " + str(Globals.wave_num)
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate", Color.TRANSPARENT, 1)
	fade_in_music($BGM)
	await get_tree().create_timer(1.5).timeout
	
func _on_button_pressed():
	$SelectSFX.play()
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate", Color.BLACK, 1)
	fade_out_music($BGM)
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")


func fade_in_music(player: AudioStreamPlayer, duration := 2.0):
	player.volume_db = -80.0
	player.play()
	var tween := create_tween()
	tween.tween_property(player, "volume_db", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func fade_out_music(player: AudioStreamPlayer, duration := 0.8):
	var tween := create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(player, "stop"))
