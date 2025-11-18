class_name NPC extends CharacterBase
@onready var main: Main = $/root/Main
@onready var dialog_box: DialogBox = $DialogBox
@onready var interact_label: Label3D = $InteractLabel

func _ready():
	dialog_box.set_visible(false)
	interact_label.scale = Vector3.ZERO

func _process(_delta: float) -> void:
	interact_label.scale = lerp(interact_label.scale, Vector3.ONE if main.player.can_talk_to == self and not dialog_box.visible else Vector3.ZERO, _delta * 10.0)

func _on_interaction_zone_body_entered(body: Node3D) -> void:
	var player = body as Player
	if player:
		player.can_talk_to = self

func _on_interaction_zone_body_exited(body: Node3D) -> void:
	var player = body as Player
	if player:
		dialog_box.set_visible(false)
		if (player.can_talk_to == self):
			player.can_talk_to = null

func talk():
	dialog_box.set_visible(true)
	dialog_box.write_text("blabla")
