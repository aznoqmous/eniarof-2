class_name CharacterBase extends RigidBody3D

@onready var main : Main = $/root/Main
@onready var sprite_container: Node3D = $SpriteContainer
@onready var ground_ray_cast_3d: RayCast3D = $GroundRayCast3D
@onready var charge_rebound_area_3d: Area3D = $ChargeReboundArea3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var walking_player: AnimationPlayer = $WalkingAnim
var is_walking:= false


@onready var tongue_container: Node3D = $SpriteContainer/Sprite3D/TongueContainer
@onready var tongue_mesh: MeshInstance3D = $SpriteContainer/Sprite3D/TongueContainer/TongueMesh
@onready var tongue_ray_cast: RayCast3D = $SpriteContainer/Sprite3D/TongueContainer/TongueRayCast
@onready var tongue_area_3d: Area3D = $SpriteContainer/Sprite3D/TongueContainer/TongueArea3D

@export_category("Sounds")
@export var jump_sound: FmodEventEmitter3D
@export var charge_sound: FmodEventEmitter3D
@export var tongue_sound: FmodEventEmitter3D
@export var rebound_sound: FmodEventEmitter3D
@export var tongue_return_sound: FmodEventEmitter3D
@export var break_wood_sound: FmodEventEmitter3D
@export var break_stone_sound: FmodEventEmitter3D

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
@export var tongue_guided_angle := 45.0
var tongue_animation_duration := 0.5
var tongue_guided_steps = 5
var is_tonguing := false
var tongue_length := 0.0
var tongue_tween : Tween
var tongue_target_position : Vector3

@export_category("Modifiers")
@export var JUMP_MODIFIER = 1.0
@export var CHARGE_MODIFIER = 1.0
@export var TONGUE_MODIFIER = 1.0

var last_walking_position : Vector3

var is_grounded := false:
	get: return ground_ray_cast_3d.is_colliding()

func _ready() -> void:
	walking_player.current_animation = "walk"
	charge_rebound_area_3d.body_entered.connect(handle_charge_rebound)
	hide_tongue()
	
func _process(_delta: float) -> void:
	if current_movement.x > 0.1 or current_movement.x < -0.1 or current_movement.z > 0.1 or current_movement.z < -0.1:
		if not is_charging:
			walking_player.play()
	else:
			walking_player.stop()
	if not is_grounded or is_charging or is_tonguing:
		walking_player.stop()
	
	if is_grounded:
		last_walking_position = ground_ray_cast_3d.get_collision_point()
		
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)
	
	if main:
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
	linear_velocity += Vector3.UP * JUMP_SPEED * JUMP_MODIFIER
	ground_ray_cast_3d.enabled = false
	jumped.emit()
	jump_sound.play()
	animation_player.current_animation = "jump"
	animation_player.play()
	
func charge() -> void:
	if not is_grounded: return;
	if is_charging: return;
	if is_rebounding: return;
	if is_tonguing: return;
	var charge_movement : Vector3 = current_movement.normalized() * CHARGE_SPEED * CHARGE_MODIFIER
	charge_movement.y = 0
	current_movement = charge_movement
	ACCELERATION = 0
	is_charging = true
	charged.emit()
	charge_sound.play()
	animation_player.current_animation = "charge"
	animation_player.play()
	
	await get_tree().create_timer(0.1).timeout
	
	is_charging = false
	ACCELERATION = BASE_ACCELERATION
	
	

func hide_tongue():
	tongue_mesh.mesh.size.y = 0.0
	tongue_mesh.mesh.center_offset.z = 0.0
	
func tongue(direction):
	if is_tonguing: return;
	is_tonguing = true
	tongued.emit()
	tongue_sound.play()
	
	var tongue_distance = MAX_TONGUE_DISTANCE * TONGUE_MODIFIER
	tongue_area_3d.position = Vector3.ZERO
	tongue_area_3d.monitoring = true
	
	tongue_target_position = global_position + direction.normalized() * tongue_distance
	tongue_container.rotation.y = atan2(direction.x, direction.z)
	
	var start_angle = - tongue_guided_steps / 2.0
	tongue_ray_cast.target_position.z = tongue_distance
	for i in range(0.0, float(tongue_guided_steps)):
		tongue_ray_cast.rotation.y = (start_angle + i) / tongue_guided_steps * deg_to_rad(tongue_guided_angle)
		tongue_ray_cast.force_raycast_update()
		
		var rbody = tongue_ray_cast.get_collider() as RigidBody3D
		if rbody:
				tongue_target_position = rbody.global_position
				direction = rbody.global_position - global_position
				tongue_container.rotation.y = atan2(direction.x, direction.z)
	
	ACCELERATION = 0.0
	current_movement = Vector3.ZERO

	hide_tongue()
	tongue_tween = get_tree().create_tween()
	tongue_tween.tween_property(self, "tongue_length", 1.0, tongue_animation_duration)
	tongue_tween.finished.connect(func():
		tongue_return_sound.play()
		get_tree().create_tween().tween_property(self, "tongue_length", 0.0, tongue_animation_duration / 4.0)
		tongue_area_3d.monitoring = false
		is_tonguing = false
		ACCELERATION = BASE_ACCELERATION
		
		
	)
	
func handle_charge_rebound(body: Node3D) -> void:
	if is_charging and not is_rebounding:
		ACCELERATION = BASE_ACCELERATION
		var rebound_movement := position - body.position
		rebound_movement = rebound_movement.normalized() * REBOUND_SPEED
		current_movement = rebound_movement
		ACCELERATION = 0
		is_rebounding = true
		rebound_sound.play()
		await get_tree().create_timer(0.1).timeout
		is_rebounding = false
		ACCELERATION = BASE_ACCELERATION


func _on_tongue_area_3d_body_entered(body: RigidBody3D) -> void:
	tongue_area_3d.monitoring = false
	tongue_tween.stop()
	tongue_tween.finished.emit()
	if body is TonguableFoliage and self == main.player:
		if body.tonguable and body.tonguable_level <= main.player.species[SpeciesResource.ActionType.Tongue].current_level:
			body.freeze = false
			body.apply_central_impulse((global_position - body.global_position).normalized() * 10.0)
signal jumped()
signal charged()
signal tongued()
