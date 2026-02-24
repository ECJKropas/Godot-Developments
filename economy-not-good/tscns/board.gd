extends Control

const TicTacToe: PackedScene = preload("res://tscns/tic_tac_toe.tscn")

var boards: Array[Array]

var current_role: int = 0

var vision_role: int = 0

@onready var H: HBoxContainer = $H

signal board_set(description: Dictionary)

# Boards are arranged in the following mode:
# Board-0-0 Board-1-0 Board-2-0
# Board-0-1 Board-1-1 Board-2-1
# Board-0-2 Board-1-2 Board-2-2

# Board local id should be like this:
# 1 4 7
# 2 5 8
# 3 6 9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for hor in range(3):
		boards.append(Array())
		for ver in range(3):
			var new_board: Control = TicTacToe.instantiate()
			new_board.name = "Board-" + str(hor) + "-" + str(ver)
			new_board.id = Vector2i(hor, ver)
			new_board.tic_set.connect(emit_sig)
			boards[hor].append(new_board)

	for V: VBoxContainer in H.get_children():
		var V_name: String = str(V.name)
		var hor: int = int(V_name[len(V_name) - 1])
		for current_board: Control in boards[hor]:
			V.add_child(current_board)
		V.queue_sort()
	H.queue_sort()

	# The following process of getting size should be deferred
	# So just wait for the next frame
	await get_tree().process_frame
	
	# Now the size should be like (188.0, 188.0)
	# print(H.size)
	self.size = H.size
	self.custom_minimum_size = H.size
	self.position = -H.size / 2

	print(get_describe())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when a board cell is set.
func emit_sig(d: Dictionary):
	var board_name:String = str(d["name"])
	var cell_name:String = str(d["cell_name"])
	var cell_pos: Vector2 = Vector2(d["cell_pos"])
	var cell_occupied: int = d["cell_occupied"]
	var cell_local_id: int = d["cell_local_id"]
	print("Board: ", board_name, " Cell: ", cell_name, " Pos: ", cell_pos)
	board_set.emit({
		"name": self.name,
		"board_name": board_name,
		"board_pos": Vector2(int(board_name[-3]), int(board_name[-1])),
		"cell_name": cell_name,
		"cell_pos": cell_pos,
		"cell_occupied": cell_occupied,
		"cell_local_id": cell_local_id,
	})

func set_board_cell(board_pos: Vector2, cell_pos: Vector2, role: int = -1, ignore_warning: bool = false):
	boards[board_pos.x][board_pos.y].set_cell(cell_pos, role, ignore_warning)

func get_board_cell_description(board_pos: Vector2, cell_pos: Vector2) -> Dictionary:
	return boards[board_pos.x][board_pos.y].get_cell_description(cell_pos)

func get_board_description(board_pos: Vector2) -> Dictionary:
	return boards[board_pos.x][board_pos.y].get_describe()

func get_describe() -> Dictionary:
	var res: Dictionary = {
		"name": self.name,
		"boards": [],
	}
	for hor in range(3):
		res["boards"].append([])
		for ver in range(3):
			res["boards"][hor].append(boards[hor][ver].get_describe())
	return res

func set_as_describe(description: Dictionary):
	if "boards" in description:
		for hor in range(3):
			for ver in range(3):
				boards[hor][ver].set_as_describe(description["boards"][hor][ver])
