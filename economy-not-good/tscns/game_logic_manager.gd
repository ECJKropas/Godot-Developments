extends Node

@export var type:String

@onready var Board:Control=$"../HBoxContainer/VSplitContainer/BoardAlignWrapper/ScaleController/Board"
@onready var boards:Array[Array] = Board.boards

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	owner.current_role = 0
	owner.vision_role = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_turn_finish(description: Dictionary) -> void:
	owner.current_role = 1-owner.current_role
	if 'A' in type:
		owner.vision_role = owner.current_role
	
	var placed_cell:Vector2i = description["cell_pos"]
	var flag = false
	for bdA in boards:
		for bd in bdA:
			if bd.id == placed_cell:
				var cells = bd.cells
				var all_occupied:bool = true
				for hor in range(3):
					for ver in range(3):
						all_occupied = cells[hor][ver].occupied != -1 and all_occupied
				if all_occupied:
					flag = true
				bd.set_disabled(false)
			else:
				bd.set_disabled()
	
	if flag:
		for bdA in boards:
			for bd in bdA:
				bd.set_disabled(false)
