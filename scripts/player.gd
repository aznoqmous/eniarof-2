class_name Player extends CharacterBase

@onready var camera_3d: Camera3D = $Camera3D
@onready var visual_ray_cast_3d: RayCast3D = $Camera3D/VisualRayCast3D

var can_talk_to: NPC

var last_input_movement : Vector3 

@export_category("Species")
@export var species_resource : Array[SpeciesResource] # reference, not to be modified in code
var actions : Array[SpeciesResource.ActionType]
var species : Dictionary[SpeciesResource.ActionType, SpeciesResource]

@export_category("Stamina")
@export var max_stamina = 10.0
var current_stamina := 0.0


func _ready():
	super()
	for s in species_resource:
		species[s.action] = s.duplicate()
	
	reset_stamina()
	update_modifiers()
	
	jumped.connect(func():
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Jump)
			lose_stamina()
	)
	charged.connect(func():
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Charge)
			lose_stamina()
	)
	tongued.connect(func():
		if current_stamina > 0:
			register_action(SpeciesResource.ActionType.Tongue)
			lose_stamina()
	)

func _process(delta: float) -> void:
	super(delta)
	
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, delta * 5.0)
	if(can_talk_to and Input.is_action_just_pressed("Interaction")):
		can_talk_to.talk()
	
	if visual_ray_cast_3d.is_colliding():
		var foliage := visual_ray_cast_3d.get_collider() as Foliage
		foliage.hide = true
		
func _physics_process(delta: float) -> void:
	var movement := Vector3.ZERO
	if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
	if Input.is_action_pressed("MoveBack"): movement += Vector3.BACK
	if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
	if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
	if movement != Vector3.ZERO: last_input_movement = movement
	if Input.is_action_just_pressed("Jump"): jump()
	if Input.is_action_just_pressed("ActionBull"): charge()
	if Input.is_action_just_pressed("ActionTongue"): tongue(last_input_movement)
	move_toward_direction(movement, delta)
	
	super(delta)

func reset_stamina():
	current_stamina = max_stamina

func lose_stamina(value=1.0):
	current_stamina = max(0, current_stamina - value)
	if current_stamina <= 0: force_modifiers_level(0)
	
func register_action(action: SpeciesResource.ActionType, count:=1):
	species[action].action_count += count
	
func reset_action_counts():
	for s in species.values():
		s.action_count = 0

func get_most_performed_action() -> SpeciesResource.ActionType:
	var actions_copy = species.values()
	actions_copy.sort_custom(func(a,b): return a.action_count > b.action_count)
	return actions_copy[0]
	
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
