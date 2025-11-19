class_name SpeciesResource extends Resource

@export var species_name : String
@export var action : ActionType
@export var modifiers : Array[float]

var current_level := 0
var action_count := 0

enum ActionType {
	Jump,
	Charge,
	Tongue
}
