class_name Player extends CharacterBase

@onready var camera_3d: Camera3D = $Camera3D
@onready var visual_ray_cast_3d: RayCast3D = $Camera3D/VisualRayCast3D

var can_talk_to: NPC

func _process(_delta: float) -> void:
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)
	if(can_talk_to and Input.is_action_just_pressed("Interaction")):
		can_talk_to.talk()
	
	if visual_ray_cast_3d.is_colliding():
		var foliage := visual_ray_cast_3d.get_collider() as Foliage
		foliage.hide = true
		
func _physics_process(_delta: float) -> void:
	var movement := Vector3.ZERO
	if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
	if Input.is_action_pressed("MoveBack"): movement += Vector3.BACK
	if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
	if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
	if Input.is_action_just_pressed("Jump"): jump()
	if Input.is_action_just_pressed("ActionBull"): charge()
	move_toward_direction(movement, _delta)
	
	super(_delta)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if is_charging and not is_rebounding:
		print("wow")
		ACCELERATION = BASE_ACCELERATION
		var rebound_movement := position - body.position
		rebound_movement = rebound_movement.normalized() * REBOUND_SPEED
		current_movement = rebound_movement
		ACCELERATION = 0
		is_rebounding = true
		
		await get_tree().create_timer(0.1).timeout
		
		is_rebounding = false
		ACCELERATION = BASE_ACCELERATION
