class_name CharacterBase extends RigidBody3D

@onready var sprite_container: Node3D = $SpriteContainer
@onready var ground_ray_cast_3d: RayCast3D = $GroundRayCast3D

@export_category("Movement")
@export var SPEED := 3.0
@export var JUMP_SPEED := 10.0
@export var BASE_ACCELERATION := 10.0
var ACCELERATION := BASE_ACCELERATION
var current_speed := 0.0
var current_movement := Vector3.ZERO

@export var CHARGE_SPEED := 10.0
@export var REBOUND_SPEED := 5.0
var is_charging := false
var is_rebounding:= false

var is_grounded := false:
	get: return ground_ray_cast_3d.is_colliding()

func _ready() -> void:
	body_entered.connect(handle_body_entered)

func _process(_delta: float) -> void:
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)

func _physics_process(_delta: float) -> void:
	
	ground_ray_cast_3d.force_raycast_update()
	if ground_ray_cast_3d.enabled and is_grounded: linear_velocity.y = 0.0
	
	linear_velocity = Vector3(current_movement.x * SPEED, linear_velocity.y, current_movement.z * SPEED)
	ground_ray_cast_3d.enabled = true

func move_toward_direction(direction:Vector3, _delta: float):
	current_movement = lerp(current_movement, direction.normalized(), _delta * ACCELERATION)

func jump() -> void:
	if not is_grounded: return;
	linear_velocity += Vector3.UP * JUMP_SPEED
	ground_ray_cast_3d.enabled = false
	
func charge() -> void:
	if not is_grounded: return;
	if is_charging: return;
	if is_rebounding: return;
	var charge_movement := current_movement.normalized() * CHARGE_SPEED
	charge_movement.y = 0
	current_movement = charge_movement
	ACCELERATION = 0
	is_charging = true
	
	await get_tree().create_timer(0.1).timeout
	
	is_charging = false
	ACCELERATION = BASE_ACCELERATION
	
func handle_body_entered(body: Node3D):
	if body.get_collision_layer_value(3) and is_charging:
		print("wow")
		is_charging = false
		ACCELERATION = BASE_ACCELERATION
		var rebound_movement := position - body.position
		rebound_movement = rebound_movement.normalized() * REBOUND_SPEED
		current_movement = rebound_movement
		ACCELERATION = 0
		is_rebounding = true
		
		await get_tree().create_timer(0.1).timeout
		
		is_rebounding = false
		ACCELERATION = BASE_ACCELERATION
		
