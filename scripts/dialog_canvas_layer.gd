class_name DialogCanvasLayer extends CanvasLayer

@onready var main: Main = $/root/Main
@onready var name_margin_container: MarginContainer = $Control/DialogContainer/NameMarginContainer
@onready var name_rich_text_label: RichTextLabel = $Control/DialogContainer/NameMarginContainer/NameRichTextLabel
@onready var dialog_rich_text_label: RichTextLabel = $Control/DialogContainer/DialogControl/DialogRichTextLabel
@onready var dialog_arrow: Control = $Control/DialogContainer/DialogControl/DialogArrow
@onready var dialog_arrow_texture: TextureRect = $Control/DialogContainer/DialogControl/DialogArrow/DialogArrowTexture

@export var char_speed := 0.02
@export var space_speed := 0.1
@export var dot_speed := 0.2
var talking_npc : NPC
var base_speed = 1.0

var speeches : Array
var current_speech_index = 0
var is_writing = false

func _ready():
	set_visible(false)

func _process(delta: float) -> void:
	dialog_arrow_texture.position.x = sin(main.get_time() * TAU) * 5.0

func talk(speech: String, npc: NPC):
	if not visible:
		talking_npc = npc
		talking_npc.speech_bubble.set_visible(true)
		set_visible(true)
		speech_sequence(speech)
		name_rich_text_label.text = npc.npc_name if npc.npc_name else "???"
		name_margin_container.size.x = 0
		return;
		
	if is_writing:
		base_speed = 20.0
		
	if not is_writing:
		current_speech_index += 1.0
		if current_speech_index >= speeches.size():
			await get_tree().create_timer(0.1).timeout
			set_visible(false)
			talking_npc.speech_bubble.set_visible(false)
			talking_npc = null
		else: write_text(speeches[current_speech_index])

func speech_sequence(speech: String):
	if is_writing: return;
	speeches = Array(speech.split("|")).map(func(a: String): return a.strip_edges())
	current_speech_index = 0
	write_text(speeches[0])

func write_text(text: String):
	dialog_arrow.set_visible(false)
	text = text.replace("[species]", str("[b]",main.player.current_species.species_name, "[/b]"))
	dialog_rich_text_label.text = ""
	var is_tag = false
	is_writing = true
	base_speed = 1.0
	for character in text:
		dialog_rich_text_label.text += character
		if not is_tag and character == "[": is_tag = true
		if character == "]": is_tag = false
		
		var dialog_speed = randf_range(char_speed, char_speed * 2.0)
		if character == " ": dialog_speed = space_speed
		if character == ".": dialog_speed = dot_speed
		if not is_tag:
			await get_tree().create_timer(dialog_speed / base_speed).timeout
			
	dialog_arrow.set_visible(true)
	is_writing = false
