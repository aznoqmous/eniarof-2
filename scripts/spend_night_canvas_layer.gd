class_name SpendNightCanvasLayer extends CanvasLayer

@onready var main: Main = $/root/Main
@onready var night_overlay_control: Control = $NightOverlayControl
@onready var spend_night_button: Button = $Control/SpendNightButton
@onready var night_confirm_button: Button = $NightOverlayControl/NightConfirmButton

var animation_duration = 1.0

func _ready() -> void:
	spend_night_button.pressed.connect(spend_night)
	night_confirm_button.pressed.connect(close)

func spend_night():
	spend_night_button.set_visible(false)
	night_overlay_control.set_visible(true)
	night_overlay_control.modulate.a = 0.0
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 1.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout

func close():
	get_tree().create_tween().tween_property(night_overlay_control, "modulate:a", 0.0, animation_duration)
	await get_tree().create_timer(animation_duration).timeout
	night_overlay_control.set_visible(false)
	main.player.current_species = main.player.species[main.player.get_most_performed_action()]
	main.player.reset_action_counts()
	main.player.reset_stamina()
