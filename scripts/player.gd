class_name Player extends CharacterBase

@onready var main: Main = $/root/Main
@onready var camera_3d: Camera3D = $Camera3D
@onready var visual_ray_cast_3d: RayCast3D = $Camera3D/VisualRayCast3D

var can_talk_to: NPC

var last_input_movement : Vector3 

@export_category("Species")
@export var species_resource : Array[SpeciesResource] # reference, not to be modified in code
@export var species_sprites : Dictionary[SpeciesResource.ActionType, Sprite3D]
var actions : Array[SpeciesResource.ActionType]
var species : Dictionary[SpeciesResource.ActionType, SpeciesResource]
var current_species : SpeciesResource

@export_category("Stamina")
@export var max_stamina = 10.0
var current_stamina := 0.0

func _ready():
	super()
	
	for s in species_resource:
		species[s.action] = s.duplicate()
	current_species = species.values().pick_random()
	update_species_sprites()
	
	reset_stamina()
	update_modifiers()
	
	jumped.connect(func():
		jump_sound.set_parameter("Lapin_State", species[SpeciesResource.ActionType.Jump].current_level)
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Jump)
			lose_stamina()
		
	)
	charged.connect(func():
		charge_sound.set_parameter("Belier_State", species[SpeciesResource.ActionType.Charge].current_level)
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Charge)
			lose_stamina()
	)
	tongued.connect(func():
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Tongue)
			lose_stamina()
	)
	charge_rebound_area_3d.body_entered.connect(handle_foliage_charge)


func _process(delta: float) -> void:
	super(delta)
	
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, delta * 5.0)
	if(can_talk_to and Input.is_action_just_pressed("Interaction")):
		can_talk_to.talk()
	
	if visual_ray_cast_3d.is_colliding():
		var foliage := visual_ray_cast_3d.get_collider() as Foliage
		foliage.is_hidden = true
		
func _physics_process(delta: float) -> void:
	var movement := Vector3.ZERO
	if not main.is_dialog:
		if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
		if Input.is_action_pressed("MoveBack"): movement += Vector3.BACK
		if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
		if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
		if movement != Vector3.ZERO: last_input_movement = movement
		if Input.is_action_just_pressed("Jump"): jump()
		if Input.is_action_just_pressed("ActionBull"): charge()
		if Input.is_action_just_pressed("ActionTongue"): tongue(last_input_movement)
	
	var grounded_ratio = 1.0 if is_grounded or charge_rebound_area_3d.get_overlapping_bodies().size() <= 0.0 else 0.0
	move_toward_direction(movement * grounded_ratio, delta)
	
	super(delta)

func reset_stamina():
	current_stamina = max_stamina

func lose_stamina(value=1.0):
	current_stamina = max(0, current_stamina - value)
	if current_stamina <= 0:
		main.spend_night_canvas_layer.spend_night_button.set_visible(true)
		force_modifiers_level(0)
	
func register_action(action: SpeciesResource.ActionType, count:=1):
	species[action].action_count += count
	
func reset_action_counts():
	for s in species.values():
		s.action_count = 0

func get_most_performed_action() -> SpeciesResource.ActionType:
	var actions_copy = species.values()
	actions_copy.sort_custom(func(a,b): return a.action_count > b.action_count)
	return actions_copy[0].action

func force_modifiers_level(level=0):
	for s in species.values():
		match s.action:
			SpeciesResource.ActionType.Jump:
				JUMP_MODIFIER = s.modifiers[level]
			SpeciesResource.ActionType.Charge:
				CHARGE_MODIFIER = s.modifiers[level]
			SpeciesResource.ActionType.Tongue:
				TONGUE_MODIFIER = s.modifiers[level]
				
func update_modifiers():
	for s in species.values():
		match s.action:
			SpeciesResource.ActionType.Jump:
				JUMP_MODIFIER = s.modifiers[s.current_level]
			SpeciesResource.ActionType.Charge:
				CHARGE_MODIFIER = s.modifiers[s.current_level]
			SpeciesResource.ActionType.Tongue:
				TONGUE_MODIFIER = s.modifiers[s.current_level]

func handle_foliage_charge(foliage: RigidFoliage):
	if not is_charging: return;
	if foliage.charge_breakable and foliage.charge_breakable_level <= species[SpeciesResource.ActionType.Charge].current_level:
		if foliage.charge_breakable_level == 1:
			break_wood_sound.play()
		elif foliage.charge_breakable_level == 2:
			break_stone_sound.play()
		foliage.break_self()

func update_species_sprites():
	for spec in species.values():
		species_sprites[spec.action].texture = spec.sprites[spec.current_level]
