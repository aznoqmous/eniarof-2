class_name Main extends Node3D
@onready var player: Player = $Player
@onready var camera_container: Node3D = $CameraContainer

func _process(delta):
	#camera_container.global_position = lerp(camera_container.global_position, player.global_position, delta * 5.0)
	pass
