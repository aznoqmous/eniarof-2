class_name CharacterBase extends RigidBody3D

@onready var sprite_container: Node3D = $SpriteContainer
@onready var ground_ray_cast_3d: RayCast3D = $GroundRayCast3D
@onready var charge_rebound_area_3d: Area3D = $ChargeReboundArea3D

@onready var tongue_container: Node3D = $TongueContainer
@onready var tongue_mesh: MeshInstance3D = $TongueContainer/TongueMesh
@onready var tongue_area_3d: Area3D = $TongueContainer/TongueArea3D

@export_category("Movement")
@export var SPEED := 3.0
@export var BASE_ACCELERATION := 10.0
var ACCELERATION := BASE_ACCELERATION
var current_speed := 0.0
var current_movement := Vector3.ZERO

@export_category("Jump")
@export var JUMP_SPEED := 10.0

@export_category("Charge")
@export var CHARGE_SPEED := 10.0
@export var REBOUND_SPEED := 5.0
var is_charging := false
var is_rebounding := false

@export_category("Tongue")
@export var MAX_TONGUE_DISTANCE := 10
var is_tonguing := false
var tongue_length := 0.0
var tongue_tween : Tween
var tongue_target_position : Vector3

var is_grounded := false:
	get: return ground_ray_cast_3d.is_colliding()

func _ready() -> void:
	charge_rebound_area_3d.body_entered.connect(handle_charge_rebound)
	hide_tongue()
	
func _process(_delta: float) -> void:
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)
	
	var tongue_distance = tongue_container.global_position - tongue_target_position
	tongue_mesh.mesh.size.y =  tongue_distance.length() * tongue_length
	tongue_mesh.mesh.center_offset.z =  tongue_distance.length() / 2.0 * tongue_length
	tongue_area_3d.global_position =  lerp(global_position, tongue_target_position, tongue_length)
	
func _physics_process(_delta: float) -> void:
	
	ground_ray_cast_3d.force_raycast_update()
	if ground_ray_cast_3d.enabled and is_grounded: linear_velocity.y = 0.0
	
	linear_velocity = Vector3(current_movement.x * SPEED, linear_velocity.y, current_movement.z * SPEED)
	ground_ray_cast_3d.enabled = true

func move_toward_direction(direction:Vector3, _delta: float):
	current_movement = lerp(current_movement, direction.normalized(), _delta * ACCELERATION)

func jump() -> void:
	if not is_grounded: return;
	if is_charging: return;
	if is_rebounding: return;
	if is_tonguing: return;
	linear_velocity += Vector3.UP * JUMP_SPEED
	ground_ray_cast_3d.enabled = false
	
func charge() -> void:
	if not is_grounded: return;
	if is_charging: return;
	if is_rebounding: return;
	if is_tonguing: return;
	var charge_movement := current_movement.normalized() * CHARGE_SPEED
	charge_movement.y = 0
	current_movement = charge_movement
	ACCELERATION = 0
	is_charging = true
	
	await get_tree().create_timer(0.1).timeout
	
	is_charging = false
	ACCELERATION = BASE_ACCELERATION

func hide_tongue():
	tongue_mesh.mesh.size.y = 0.0
	tongue_mesh.mesh.center_offset.z = 0.0
	
func tongue():
	if is_tonguing: return;
	
	is_tonguing = true
	
	tongue_target_position = current_movement.normalized() * MAX_TONGUE_DISTANCE
	var animation_duration = tongue_target_position.length() * 0.1
	tongue_container.look_at(-tongue_target_position)
	tongue_area_3d.position = Vector3.ZERO
	tongue_area_3d.monitoring = true
	
	ACCELERATION = 0.0
	current_movement = Vector3.ZERO

	hide_tongue()
	tongue_tween = get_tree().create_tween()
	tongue_tween.tween_property(self, "tongue_length", 1.0, animation_duration)
	tongue_tween.finished.connect(func():
		get_tree().create_tween().tween_property(self, "tongue_length", 0.0, animation_duration / 4.0)
		tongue_area_3d.monitoring = false
		is_tonguing = false
		ACCELERATION = BASE_ACCELERATION
	)
	#tween.tween_property(tongue_mesh.mesh, "size:y", distance.length(), animation_duration)
	#tween.tween_property(tongue_mesh.mesh, "center_offset:z", distance.length() / 2.0, animation_duration)
	#tween.tween_property(tongue_area_3d, "global_position", target_position, animation_duration)
	
	#await get_tree().create_timer(animation_duration).timeout
	#
	#get_tree().create_tween().tween_property(tongue_mesh.mesh, "size:y", 0.0, animation_duration / 4.0)
	#get_tree().create_tween().tween_property(tongue_mesh.mesh, "center_offset:z", 0.0, animation_duration / 4.0)
#
	#tongue_area_3d.monitoring = false
	#is_tonguing = false
	#ACCELERATION = BASE_ACCELERATION
	
func handle_charge_rebound(body: Node3D) -> void:
	if is_charging and not is_rebounding:
		ACCELERATION = BASE_ACCELERATION
		var rebound_movement := position - body.position
		rebound_movement = rebound_movement.normalized() * REBOUND_SPEED
		current_movement = rebound_movement
		ACCELERATION = 0
		is_rebounding = true
		await get_tree().create_timer(0.1).timeout
		is_rebounding = false
		ACCELERATION = BASE_ACCELERATION


func _on_tongue_area_3d_body_entered(body: RigidBody3D) -> void:
	tongue_area_3d.monitoring = false
	tongue_tween.stop()
	tongue_tween.finished.emit()
	body.apply_central_impulse((global_position - body.global_position).normalized() * 10.0)
