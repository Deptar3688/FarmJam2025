extends Control


func _ready():
	$VBoxContainer/RichTextLabel2.text = "You reached wave: " + str(Globals.wave_num)
	var tween = create_tween()
	tween.tween_property($BlackFade, "modulate", Color.TRANSPARENT, 1)
	await get_tree().create_timer(1.5).timeout
	
func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
