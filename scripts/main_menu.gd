extends Control

@onready var onboarding_scene = preload("res://scenes/unboarding_lapin.tscn")

@onready var UI_audio: FmodEventEmitter2D = $FmodBankLoader/UI_Click
@onready var MusicMenu_audio: FmodEventEmitter2D = $FmodBankLoader/MusicMenu

func _ready() -> void:
	MusicMenu_audio.play()

func _on_start_pressed() -> void:
	MusicMenu_audio.stop()
	UI_audio.play_one_shot()
	get_tree().change_scene_to_packed(onboarding_scene)
	
	

func _on_quit_pressed() -> void:
	MusicMenu_audio.stop()
	UI_audio.play_one_shot()
	get_tree().quit()
