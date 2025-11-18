class_name NPC extends CharacterBase

func _on_interaction_zone_body_entered(body: Node3D) -> void:
	var player = body as Player
	if player:
		player.can_talk_to = self

func _on_interaction_zone_body_exited(body: Node3D) -> void:
	var player = body as Player
	if player:
		if (player.can_talk_to == self):
			player.can_talk_to = null

func talk():
	print("blabla")
