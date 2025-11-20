class_name SpendNightCanvasLayer extends CanvasLayer

@onready var main: Main = $/root/Main
@onready var night_overlay_control: Control = $NightOverlayControl
@onready var spend_night_button: Button = $Control/SpendNightButton
@onready var night_confirm_button: Button = $NightOverlayControl/NightConfirmButton

@onready var rabbit_container: Control = $NightOverlayControl/Control/RabbitContainer
@onready var ram_container: Control = $NightOverlayControl/Control/RamContainer
@onready var anteater_container: Control = $NightOverlayControl/Control/AnteaterContainer

var animation_duration = 1.0

func _ready() -> void:
	spend_night_button.pressed.connect(spend_night)
	night_confirm_button.pressed.connect(close)
	night_overlay_control.set_visible(false)

func spend_night():
	spend_night_button.set_visible(false)
	night_overlay_control.set_visible(true)
	night_overlay_control.modulate.a = 0.0
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 1.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	
	var total = 0
	total += main.player.species[SpeciesResource.ActionType.Jump].action_count
	total += main.player.species[SpeciesResource.ActionType.Charge].action_count
	total += main.player.species[SpeciesResource.ActionType.Tongue].action_count
	
	var duration = 1.0
	evolve(SpeciesResource.ActionType.Jump, total, rabbit_container, duration)
	evolve(SpeciesResource.ActionType.Charge, total, ram_container, duration)
	evolve(SpeciesResource.ActionType.Tongue, total, anteater_container, duration)
	main.player.update_species_sprites()
	
func evolve(action : SpeciesResource.ActionType, total_actions : int, texture, duration: float):
	var ratio = float(main.player.species[action].action_count) / float(total_actions)
	if ratio < 0.16: main.player.species[action].current_level = clamp(main.player.species[action].current_level - 1, 0, 2)
	if ratio > 0.32: main.player.species[action].current_level = clamp(main.player.species[action].current_level + 1, 0, 2)
	get_tree().create_tween().tween_property(
		texture, 
		"scale", 
		Vector2.ONE * lerp(1, 2, float(main.player.species[action].current_level) / 2.0),
		duration
	)
	


func close():
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 0.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	night_overlay_control.set_visible(false)
	main.player.current_species = main.player.species[main.player.get_most_performed_action()]
	main.player.reset_action_counts()
	main.player.reset_stamina()
	main.player.update_modifiers()
