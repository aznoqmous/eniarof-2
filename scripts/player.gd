class_name Player extends CharacterBase
@onready var camera_3d: Camera3D = $Camera3D
var can_talk_to: NPC

func _process(_delta: float) -> void:
	sprite_container.rotation.y = lerp(sprite_container.rotation.y, PI if current_movement.x < 0 else 0.0, _delta * 5.0)
	if(can_talk_to and Input.is_action_just_pressed("Interaction")):
		can_talk_to.talk()

func _physics_process(_delta: float) -> void:
	var movement := Vector3.ZERO
	if Input.is_action_pressed("MoveForward"): movement += Vector3.FORWARD
	if Input.is_action_pressed("MoveBack"): movement += Vector3.BACK
	if Input.is_action_pressed("MoveLeft"): movement += Vector3.LEFT
	if Input.is_action_pressed("MoveRight"): movement += Vector3.RIGHT
	if Input.is_action_just_pressed("Jump"): jump()
	move_toward_direction(movement, _delta)
	
	super(_delta)
	
