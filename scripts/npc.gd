class_name NPC extends CharacterBase

@onready var main: Main = $/root/Main
@onready var dialog_box: DialogBox = $DialogBox
@onready var interact_label: Label3D = $InteractLabel

var is_interactable:bool:
	get: return main.player.can_talk_to == self

@export_category("Actions")
@export var actions: Array[NPCActionResource]
var action_index := 0
var action_start_time := 0
var current_action: NPCActionResource
var starting_position: Vector3
var action_direction: Vector3
var max_action_distance = 1

@export_multiline var speech : String

func _ready():
	starting_position = global_position
	dialog_box.set_visible(false)
	interact_label.scale = Vector3.ZERO
	if actions.size(): start_action(actions[0])

func _process(delta: float) -> void:
	super(delta)
	interact_label.scale = lerp(interact_label.scale, Vector3.ONE if is_interactable and not dialog_box.visible else Vector3.ZERO, delta * 10.0)

func _physics_process(delta: float) -> void:
	live(delta)
	super(delta)
	
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
	dialog_box.write_text(speech if not main.is_night else main.night_speechs.pick_random())

func live(delta):
	if not current_action: return;
	if is_interactable:
		current_movement = Vector3.ZERO
		return;
	if main.get_time() - action_start_time > current_action.time:
		action_index = (action_index + 1) % actions.size()
		start_action(actions[action_index])
		
	match current_action.action:
		NPCActionResource.Action.Idle: pass
		NPCActionResource.Action.Move:
			move_toward_direction(Vector3(action_direction.x, 0, action_direction.z), delta)
			pass
		NPCActionResource.Action.Jump:
			if is_grounded:
				move_toward_direction(Vector3.ZERO, delta)
		NPCActionResource.Action.Charge:
			move_toward_direction(Vector3.ZERO, delta)
		NPCActionResource.Action.Tongue:
			move_toward_direction(Vector3.ZERO, delta)

		
func start_action(action_resource: NPCActionResource):
	current_action = action_resource
	action_start_time = main.get_time()
	match current_action.action:
		NPCActionResource.Action.Idle:
			current_movement = Vector3.ZERO
		NPCActionResource.Action.Jump:
			update_action_direction()
			current_movement = action_direction
			jump()
		NPCActionResource.Action.Charge:
			update_action_direction()
			current_movement = action_direction
			charge()
		NPCActionResource.Action.Tongue:
			update_action_direction()
			tongue(action_direction)
		NPCActionResource.Action.Move:
			update_action_direction()
			pass

func update_action_direction():
	action_direction = Vector3.LEFT.rotated(Vector3.UP, randf() * TAU)
	if global_position.distance_to(starting_position) > current_action.max_start_position_distance:
		action_direction = (starting_position - global_position).normalized().rotated(Vector3.UP, randf_range(-1, 1) * PI / 5.0)
