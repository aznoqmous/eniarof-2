class_name Player extends RigidBody3D
@onready var camera_3d: Camera3D = $Camera3D
@onready var sprite_container: Node3D = $SpriteContainer
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var ground_ray_cast_3d: RayCast3D = $GroundRayCast3D

@export_category("Movement")
@export var SPEED := 3.0
@export var JUMP_SPEED := 3.0
@export var GRAVITY := 3.0
@export var ACCELERATION := 5.0
var current_speed := 0.0
var current_movement := Vector3.ZERO
var is_grounded := false:
	get:
		return ground_ray_cast_3d.is_colliding()

func _process(_delta: float) -> void:
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)
func _physics_process(_delta: float) -> void:
	var movement := Vector3.ZERO
	if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
	if Input.is_action_pressed("MoveBack"): movement += Vector3.BACK
	if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
	if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
	
	ground_ray_cast_3d.force_raycast_update()
	
	if Input.is_action_just_pressed("Jump") and is_grounded: linear_velocity += Vector3.UP * JUMP_SPEED
	elif is_grounded: linear_velocity.y = 0.0
	
	current_movement = lerp(current_movement, movement, _delta * ACCELERATION)
	linear_velocity = Vector3(current_movement.x * SPEED, linear_velocity.y, current_movement.z * SPEED)
	
