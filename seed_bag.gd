extends Area2D

var is_currently_hovered := false

# Called when the node enters the scene tree for the first time.
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	$Sprite2D.material.set_shader_parameter("thickness", 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_exited():
	is_currently_hovered = false
	$Sprite2D.material.set_shader_parameter("thickness", 0)
	
func _on_mouse_entered():
	is_currently_hovered = true
	$Sprite2D.material.set_shader_parameter("thickness", 2)
