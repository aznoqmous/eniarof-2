class_name RigidFoliage extends Foliage

@export var charge_breakable := false
@export var charge_breakable_level := 0

func break_self():
	queue_free()
