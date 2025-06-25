class_name Crop
extends Resource

@export var name: String
@export var sprite: Texture2D
@export var health: Array[int] # changes depending on growth stage
enum State {GROWING, MATURE, ENCHANCED}
@export var attack_dmg: int
@export var attack_spd: int
@export var attack_range: int
