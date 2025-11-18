class_name NPCActionResource extends Resource

@export var time := 0
@export var direction: Vector2
@export var action: Action

enum Action {
	Idle,
	Move,
	Jump,
	Charge,
	RandomMove
}
