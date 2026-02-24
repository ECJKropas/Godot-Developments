extends Control

const Cell: PackedScene = preload("res://tscns/cell.tscn")

@export var id: Vector2i = Vector2i(0, 0)
@export var disabled: bool = false
@export var winner_determined: bool = false
@export var winner_role: int = -1 # Defaut(No winner) set as -1

var cells: Array[Array]

# The following are the variables that need to be synchronized with the root node.
var textures: Array[Texture2D]
var current_role: int = 0
var vision_role: int = -1  # This variable represents the role corresponding to the current perspective and is obtained in real time from the root node.


@onready var H: HBoxContainer = $H
@onready var WinnerDisplay: TextureRect = $WinnerDisplay

signal tic_set(description: Dictionary)

# Cells are arranged in the following mode:
# Cell-0-0 Cell-1-0 Cell-2-0
# Cell-0-1 Cell-1-1 Cell-2-1
# Cell-0-2 Cell-1-2 Cell-2-2

# Cell local id should be like this:
# 1 4 7
# 2 5 8
# 3 6 9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for hor in range(3):
		cells.append(Array())
		for ver in range(3):
			var new_cell: Control = Cell.instantiate()
			new_cell.name = "Cell-" + str(hor) + "-" + str(ver)
			new_cell.set_cell.connect(emit_sig)
			cells[hor].append(new_cell)
	
	for V: VBoxContainer in H.get_children():
		var V_name: String = str(V.name)
		var hor: int = int(V_name[len(V_name) - 1])
		for current_cell: Control in cells[hor]:
			V.add_child(current_cell)
		V.queue_sort()
	H.queue_sort()
	
	# The following process of getting size should be deferred
	# So just wait for the next frame
	await get_tree().process_frame
	
	# Now the size should be like (56.0, 56.0)
	# print(H.size)
	self.size = H.size
	self.custom_minimum_size = H.size
	self.position = -H.size / 2

# This function is used to get variables from the root node.
func get_data_from_root():
	textures = get_tree().current_scene.textures
	current_role = get_tree().current_scene.current_role
	vision_role = get_tree().current_scene.vision_role


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Called when a cell is set.
func emit_sig(d: Dictionary):
	var cell_name:String = str(d["name"])
	var cell_occupied: int = d["occupied"]
	var cell_pos: Vector2 = Vector2(int(cell_name[-3]), int(cell_name[-1]))
	recaculate_winner()
	tic_set.emit({
		"name": self.name,
		"cell_name": cell_name,
		"cell_pos": cell_pos,
		"cell_occupied": cell_occupied,
		"cell_local_id": cell_pos.x * 3 + cell_pos.y + 1,
		"winner_determined": winner_determined,
		"winner_role": winner_role,
	})

func set_cell(cell_pos: Vector2,role: int = -1, ignore_warning: bool = false):
	get_data_from_root()
	cells[cell_pos.x][cell_pos.y].set_as(role, ignore_warning)

func get_cell_description(cell_pos: Vector2) -> Dictionary:
	return cells[cell_pos.x][cell_pos.y].get_describe()

func get_describe() -> Dictionary:
	get_data_from_root()
	recaculate_winner()
	var res: Dictionary = {
		"name": self.name,
		"disabled": disabled,
		"id": id,
		"winner_determined": winner_determined,
		"winner_role": winner_role,
		"cells": [],
	}
	for hor in range(3):
		res["cells"].append([])
		for ver in range(3):
			res["cells"][hor].append(cells[hor][ver].get_describe())
	return res

func set_as_describe(description: Dictionary):
	if "disabled" in description:
		set_disabled(description["disabled"])
	if "id" in description:
		id = description["id"]
	if "winner_determined" in description:
		self.winner_determined = description["winner_determined"]
	if "winner_role" in description:
		self.winner_role = description["winner_role"]
	if "cells" in description:
		for hor in range(3):
			for ver in range(3):
				cells[hor][ver].set_as_describe(description["cells"][hor][ver])		

func set_disabled(disable_or_not: bool = true):
	if disable_or_not != disabled:
		self.disabled = disable_or_not
	for hor in range(3):
		for ver in range(3):
			cells[hor][ver].set_disabled(disable_or_not)

func recaculate_winner(force_recalculate: bool = false):
	if not force_recalculate and winner_determined and winner_role != -1:
		return
	
	winner_determined = true
	winner_role = -1
	
	var winners = []
	
	# 检查行
	for row in range(3):
		var first_cell = cells[row][0].occupied
		if first_cell != -1:
			var count = 1
			for col in range(1, 3):
				if cells[row][col].occupied == first_cell:
					count += 1
			if count == 3:
				winners.append(first_cell)
	
	# 检查列
	for col in range(3):
		var first_cell = cells[0][col].occupied
		if first_cell != -1:
			var count = 1
			for row in range(1, 3):
				if cells[row][col].occupied == first_cell:
					count += 1
			if count == 3:
				winners.append(first_cell)
	
	# 检查主对角线
	var first_cell = cells[0][0].occupied
	if first_cell != -1:
		var count = 1
		for i in range(1, 3):
			if cells[i][i].occupied == first_cell:
				count += 1
		if count == 3:
			winners.append(first_cell)
	
	# 检查副对角线
	first_cell = cells[0][2].occupied
	if first_cell != -1:
		var count = 1
		for i in range(1, 3):
			if cells[i][2-i].occupied == first_cell:
				count += 1
		if count == 3:
			winners.append(first_cell)
	
	# 处理获胜者
	if winners.size() == 0:
		winner_role = -1
		winner_determined = false
	elif winners.size() == 1:
		winner_role = winners[0]
	else:
		# 多个玩家获胜，计算谁的子多
		var player_counts = {}
		for row in range(3):
			for col in range(3):
				var cell_value = cells[row][col].occupied
				if cell_value != -1:
					if cell_value in player_counts:
						player_counts[cell_value] += 1
					else:
						player_counts[cell_value] = 1
		
		var max_count = 0
		var max_player = -1
		for player in winners:
			if player in player_counts and player_counts[player] > max_count:
				max_count = player_counts[player]
				max_player = player
		
		winner_role = max_player
	
	if winner_determined:
		get_data_from_root()
		WinnerDisplay.texture = textures[winner_role]
	
