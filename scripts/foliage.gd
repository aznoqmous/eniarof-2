class_name Foliage extends Node3D
@onready var sprite_3d: Sprite3D = $Sprite3D

var hide:bool = false

func set_opacity(value):
	sprite_3d.modulate.a = value

func _process(delta):
	sprite_3d.modulate.a = lerp(sprite_3d.modulate.a, 0.5 if hide else 1.0, delta * 5.0)
	hide = false
