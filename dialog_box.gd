class_name DialogBox extends MeshInstance3D

@onready var main: Main = $/root/Main
@export var char_speed := 0.02
@export var space_speed := 0.1
@export var dot_speed := 0.2
@onready var rich_text_label: RichTextLabel = $SubViewport/Control/Container/MarginContainer/RichTextLabel
@onready var margin_container: MarginContainer = $SubViewport/Control/Container/MarginContainer

var target_y := 0
	
func _process(_delta: float) -> void:
	#look_at(main.player.camera_3d.global_position)
	pass

func write_text(text: String):
	var is_tag = false
	rich_text_label.text = ""
	margin_container.size.y = 0
	margin_container.position.y = 334
	for character in text:
		rich_text_label.text += character
		if not is_tag and character == "[": is_tag = true
		if character == "]": is_tag = false
		
		var dialog_speed = randf_range(char_speed, char_speed * 2.0)
		if character == " ": dialog_speed = space_speed
		if character == ".": dialog_speed = dot_speed
		if not is_tag:
			await get_tree().create_timer(dialog_speed).timeout
