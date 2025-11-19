class_name Main extends Node3D
@onready var player: Player = $Player

func get_time():
	return Time.get_ticks_msec() / 1000.0
