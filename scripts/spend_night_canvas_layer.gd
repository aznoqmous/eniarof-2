class_name SpendNightCanvasLayer extends CanvasLayer

@onready var main: Main = $/root/Main
@onready var night_overlay_control: Control = $NightOverlayControl
@onready var spend_night_button: Button = $Control/SpendNightButton

@onready var night_confirm_button: Button = $NightOverlayControl/HBoxContainer/NightConfirmButton
@onready var game_exit_button: Button = $NightOverlayControl/HBoxContainer/GameExitButton


@onready var night_circle: TextureRect = $NightOverlayControl/Control/NightCircle
@onready var rabbit_container: Control = $NightOverlayControl/Control/RabbitContainer
@onready var ram_container: Control = $NightOverlayControl/Control/RamContainer
@onready var anteater_container: Control = $NightOverlayControl/Control/AnteaterContainer

@onready var day_label: Label = $NightOverlayControl/DayLabel
@onready var intro_label: Label = $NightOverlayControl/IntroLabel
@onready var species_label: Label = $NightOverlayControl/SpeciesLabel

@onready var UI_audio: FmodEventEmitter2D = $/root/Main/FmodBankLoader/UI_Click
@onready var Spend_night_audio: FmodEventEmitter2D = $/root/Main/FmodBankLoader/Night_audio

@export_multiline var night_intros : Array[String]
@export var night_species_texts : Dictionary[SpeciesResource.ActionType, Array]

var animation_duration = 1.0
var current_day = 0

func _ready() -> void:
	spend_night_button.pressed.connect(spend_night)
	night_confirm_button.pressed.connect(close)
	night_overlay_control.set_visible(false)
	game_exit_button.set_visible(false)
	
	game_exit_button.pressed.connect(func():
		get_tree().quit()
	)

func _process(delta):
	night_circle.pivot_offset = night_circle.size / 2.0
	night_circle.rotation += delta * TAU / 20.0
	
func spend_night():
	UI_audio.play_one_shot()
	main.player.current_species = main.player.species[main.player.get_most_performed_action()]

	current_day += 1
	game_exit_button.set_visible(false)
	day_label.text = str("JOUR ", current_day)
	
	intro_label.modulate.a = 0.0
	species_label.modulate.a = 0.0
	
	intro_label.text = night_intros.pick_random()
	species_label.text = night_species_texts[main.player.current_species.action].pick_random()
	
	spend_night_button.set_visible(false)
	night_overlay_control.set_visible(true)
	night_confirm_button.set_visible(false)
	night_overlay_control.modulate.a = 0.0
	Spend_night_audio.play_one_shot()
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 1.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	
	get_tree().create_tween().tween_property(intro_label, "modulate:a", 1.0, 2.0)
	await get_tree().create_timer(2.0).timeout

	
	var total = 0
	total += main.player.species[SpeciesResource.ActionType.Jump].action_count
	total += main.player.species[SpeciesResource.ActionType.Charge].action_count
	total += main.player.species[SpeciesResource.ActionType.Tongue].action_count
	
	var duration = 1.0
	evolve(SpeciesResource.ActionType.Jump, total)
	evolve(SpeciesResource.ActionType.Charge, total)
	evolve(SpeciesResource.ActionType.Tongue, total)
	
	var maxed_levels = []
	if main.player.species[SpeciesResource.ActionType.Jump].current_level >= 2: maxed_levels.append(SpeciesResource.ActionType.Jump)
	if main.player.species[SpeciesResource.ActionType.Charge].current_level >= 2: maxed_levels.append(SpeciesResource.ActionType.Charge)
	if main.player.species[SpeciesResource.ActionType.Tongue].current_level >= 2: maxed_levels.append(SpeciesResource.ActionType.Tongue)
	if maxed_levels.size() > 1:
		for action in maxed_levels:
			if action != main.player.current_species.action: main.player.species[action].current_level = 1
	evolve_animation(SpeciesResource.ActionType.Jump, rabbit_container, duration)
	evolve_animation(SpeciesResource.ActionType.Charge, ram_container, duration)
	evolve_animation(SpeciesResource.ActionType.Tongue, anteater_container, duration)
	
	main.player.update_species_sprites()
	
	get_tree().create_tween().tween_property(species_label, "modulate:a", 1.0, 2.0)
	await get_tree().create_timer(2.0).timeout
	
	await get_tree().create_timer(duration + 0.5).timeout
	night_confirm_button.set_visible(true)
	game_exit_button.set_visible(current_day >= 3)


	
func evolve(action : SpeciesResource.ActionType, total_actions : int):
	var ratio = float(main.player.species[action].action_count) / float(total_actions)
	if ratio < 0.16: main.player.species[action].current_level = clamp(main.player.species[action].current_level - 1, 0, 2)
	if ratio > 0.32: main.player.species[action].current_level = clamp(main.player.species[action].current_level + 1, 0, 2)
	
func evolve_animation(action : SpeciesResource.ActionType, texture, duration: float):
	get_tree().create_tween().tween_property(
		texture, 
		"scale", 
		Vector2.ONE * lerp(1, 2, float(main.player.species[action].current_level) / 2.0),
		duration
	)
	
func close():
	UI_audio.play_one_shot()
	spend_night_end.emit()
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 0.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	night_overlay_control.set_visible(false)
	main.player.reset_action_counts()
	main.player.reset_stamina()
	main.player.update_modifiers()

signal spend_night_end()


func _on_spend_night_end() -> void:
	
	main.player.position = main.start.position
