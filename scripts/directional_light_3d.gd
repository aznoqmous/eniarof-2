extends DirectionalLight3D

@onready var main : Main = $/root/Main
	
func _process(delta: float) -> void:
	light_energy = lerp(light_energy, (main.player.current_stamina/main.player.max_stamina) * 0.9 + 0.1, delta * 5)
