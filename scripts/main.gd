class_name Main extends Node3D

@onready var player: Player = $Player
@onready var spend_night_canvas_layer: SpendNightCanvasLayer = $SpendNightCanvasLayer

@export_multiline var night_speechs : Array[String]

var is_night : bool :
	get(): return not player.current_stamina
	
func get_time():
	return Time.get_ticks_msec() / 1000.0
