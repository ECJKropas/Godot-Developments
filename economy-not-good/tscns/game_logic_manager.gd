extends Node

@export var type:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owner.current_role = 0
	owner.vision_role = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func TypeA_Turn():
	owner.current_role = 1-owner.current_role
	owner.vision_role = owner.current_role




func _on_turn_finish(description: Dictionary) -> void:
	TypeA_Turn()
