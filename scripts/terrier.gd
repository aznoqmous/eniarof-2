extends Node3D

@onready var main_scene = preload("res://main.tscn")

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("wow")
	get_tree().change_scene_to_packed(main_scene)
