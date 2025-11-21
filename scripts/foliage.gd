@tool
class_name Foliage extends CollisionObject3D
@onready var sprite_3d: Sprite3D = $Sprite3D

@export var texture: CompressedTexture2D:
	set(value):
		texture = value
		if not sprite_3d: return;
		sprite_3d.texture = value

var is_hidden := false

func _ready():
	if texture: sprite_3d.texture = texture
	
func _process(delta):
	if sprite_3d: sprite_3d.modulate.a = lerp(sprite_3d.modulate.a, 0.5 if is_hidden else 1.0, delta * 5.0)
	is_hidden = false

func set_opacity(value):
	sprite_3d.modulate.a = value
	
