extends CharacterBody2D

@export var target: Node2D
@export var tilemap: TileMapLayer

@onready var navigation_agent : NavigationAgent2D = $Navigation/NavigationAgent2D

var speed = 300
var acceleration = 7

func _physics_process(delta):
	var direction = Vector2.ZERO
	
	direction = navigation_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, acceleration*delta)
	move_and_slide()

func _on_timer_timeout():
	navigation_agent.target_position = target.global_position
	var target_pos = tilemap.to_local(target.global_position)
	var target_local = tilemap.local_to_map(target_pos)
	var path = navigation_agent.get_next_path_position()
	#print(path)
