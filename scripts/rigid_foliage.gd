@tool
class_name RigidFoliage extends Foliage

@export var charge_breakable := false
@export var charge_breakable_level := 0
@onready var sprite_3d_2: Sprite3D = $Sprite3D2

		
		
func break_self():
	queue_free()
	
func _process(delta):
	super(delta)
	if sprite_3d: sprite_3d.texture = texture
	if sprite_3d_2: sprite_3d_2.texture = texture
