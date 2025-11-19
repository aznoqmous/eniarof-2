class_name Foliage extends CollisionObject3D
@onready var sprite_3d: Sprite3D = $Sprite3D

var is_hidden := false

func set_opacity(value):
	sprite_3d.modulate.a = value

func _process(delta):
	sprite_3d.modulate.a = lerp(sprite_3d.modulate.a, 0.5 if is_hidden else 1.0, delta * 5.0)
	is_hidden = false
