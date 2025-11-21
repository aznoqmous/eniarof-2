extends Node3D

@onready var main_scene = preload("res://main.tscn")

func _on_body_entered(body: Node3D) -> void:
	get_tree().change_scene_to_packed(main_scene)
