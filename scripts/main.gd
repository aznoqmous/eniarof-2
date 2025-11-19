class_name Main extends Node3D

@onready var player: Player = $Player
@onready var spend_night_canvas_layer: SpendNightCanvasLayer = $SpendNightCanvasLayer

func get_time():
	return Time.get_ticks_msec() / 1000.0
