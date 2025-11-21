class_name Main extends Node3D

@onready var player: Player = $Player
@onready var start: Node3D = $Start
@onready var spend_night_canvas_layer: SpendNightCanvasLayer = $SpendNightCanvasLayer
@onready var dialog_canvas_layer: DialogCanvasLayer = $DialogCanvasLayer
@onready var music: FmodEventEmitter3D = $MusicStart
@onready var clair: FmodEventEmitter3D = $MusicClair
@export_multiline var night_speechs : Array[String]

var is_night : bool :
	get(): return not player.current_stamina
	
var is_dialog: bool :
	get(): return dialog_canvas_layer.visible
	
func get_time():
	return Time.get_ticks_msec() / 1000.0
	
func _ready() -> void:
	if music and clair:
		music.play()
		clair.play()
	
