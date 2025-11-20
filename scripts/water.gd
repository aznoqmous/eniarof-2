class_name Water extends Area3D


func _on_body_entered(body: CharacterBase) -> void:
	print("WATERED")
	body.global_position = body.last_walking_position
