class_name NPCActionResource extends Resource

@export var time := 0
@export var direction: Vector2
@export var action: Action
@export var max_start_position_distance: float

enum Action {
	Idle,
	Move,
	Jump,
	Charge,
	Tongue
}
