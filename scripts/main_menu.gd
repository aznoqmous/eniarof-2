extends Control

@onready var onboarding_scene = preload("res://scenes/unboarding_lapin.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(onboarding_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()
