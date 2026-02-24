extends Control

const TicTacToe: PackedScene = preload("res://tscns/tic_tac_toe.tscn")

@export var winner_determined: bool = false
@export var winner_role: int = -1 # Defaut(No winner) set as -1

var boards: Array[Array]

# The following are the variables that need to be synchronized with the root node.
@export var textures: Array[Texture2D]
var current_role: int = 0
var vision_role: int = 0  # This variable represents the role corresponding to the current perspective and is obtained in real time from the root node.


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
	self.position = -H.size * self.scale / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when a board cell is set.
func emit_sig(d: Dictionary):
	var board_name:String = str(d["name"])
	var board_winner_determined: bool = d["winner_determined"]
	var board_winner_role: int = d["winner_role"]
	var cell_name:String = str(d["cell_name"])
	var cell_pos: Vector2 = Vector2(d["cell_pos"])
	var cell_occupied: int = d["cell_occupied"]
	var cell_local_id: int = d["cell_local_id"]
	# print("Board: ", board_name, " Cell: ", cell_name, " Pos: ", cell_pos)
	recaculate_winner()
	board_set.emit({
		"name": self.name,
		"board_name": board_name,
		"board_pos": Vector2(int(board_name[-3]), int(board_name[-1])),
		"board_winner_determined": board_winner_determined,
		"board_winner_role": board_winner_role,
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
	recaculate_winner()
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
	if "winner_determined" in description:
		winner_determined = description["winner_determined"]
	if "winner_role" in description:
		winner_role = description["winner_role"]

func recaculate_winner(force_recalculate: bool = false):
	if not force_recalculate and winner_determined and winner_role != -1:
		return
	
	winner_determined = true
	winner_role = -1
	
	var winners = []
	
	# 检查行
	for row in range(3):
		var first_board = boards[row][0]
		if first_board.winner_determined and first_board.winner_role != -1:
			var count = 1
			for col in range(1, 3):
				var current_board = boards[row][col]
				if current_board.winner_determined and current_board.winner_role == first_board.winner_role:
					count += 1
			if count == 3:
				winners.append(first_board.winner_role)
	
	# 检查列
	for col in range(3):
		var first_board = boards[0][col]
		if first_board.winner_determined and first_board.winner_role != -1:
			var count = 1
			for row in range(1, 3):
				var current_board = boards[row][col]
				if current_board.winner_determined and current_board.winner_role == first_board.winner_role:
					count += 1
			if count == 3:
				winners.append(first_board.winner_role)
	
	# 检查主对角线
	var first_board = boards[0][0]
	if first_board.winner_determined and first_board.winner_role != -1:
		var count = 1
		for i in range(1, 3):
			var current_board = boards[i][i]
			if current_board.winner_determined and current_board.winner_role == first_board.winner_role:
				count += 1
		if count == 3:
			winners.append(first_board.winner_role)
	
	# 检查副对角线
	first_board = boards[0][2]
	if first_board.winner_determined and first_board.winner_role != -1:
		var count = 1
		for i in range(1, 3):
			var current_board = boards[i][2-i]
			if current_board.winner_determined and current_board.winner_role == first_board.winner_role:
				count += 1
		if count == 3:
			winners.append(first_board.winner_role)
	
	# 处理获胜者
	if winners.size() == 0:
		winner_role = -1
		winner_determined = false
	elif winners.size() == 1:
		winner_role = winners[0]
		print(winner_role,"wins")
	else:
		# 多个玩家获胜，计算谁的子多
		var player_counts = {}
		for row in range(3):
			for col in range(3):
				var current_board = boards[row][col]
				if current_board.winner_determined and current_board.winner_role != -1:
					if current_board.winner_role in player_counts:
						player_counts[current_board.winner_role] += 1
					else:
						player_counts[current_board.winner_role] = 1
		
		var max_count = 0
		var max_player = -1
		for player in winners:
			if player in player_counts and player_counts[player] > max_count:
				max_count = player_counts[player]
				max_player = player
		
		winner_role = max_player
