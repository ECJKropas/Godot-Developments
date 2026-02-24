extends Control

const Cell: PackedScene = preload("res://tscns/cell.tscn")

@export var id: Vector2i = Vector2i(0, 0)

var cells: Array[Array]

var current_role: int = 0

var vision_role: int = 0

@onready var H: HBoxContainer = $H

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
			print(new_cell.name)
			new_cell.set_cell.connect(emit_sig)
			cells[hor].append(new_cell)

	H.size = Vector2(3 * 16, 3 * 16)
	H.custom_minimum_size = H.size
	H.position = -Vector2.ONE * 3 * 8
	for V: VBoxContainer in H.get_children():
		var V_name: String = str(V.name)
		var hor: int = int(V_name[len(V_name) - 1])
		for current_cell: Control in cells[hor]:
			V.add_child(current_cell)
		V.queue_sort()
	H.queue_sort()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when a cell is set.
func emit_sig(d: Dictionary):
	var cell_name:String = str(d["name"])
	var cell_occupied: int = d["occupied"]
	var cell_pos: Vector2 = Vector2(int(cell_name[-3]), int(cell_name[-1]))
	print(cell_pos)
	tic_set.emit({
		"name": self.name,
		"cell_name": cell_name,
		"cell_pos": cell_pos,
		"cell_occupied": cell_occupied,
		"cell_local_id": cell_pos.x * 3 + cell_pos.y + 1,
	})

func set_cell(cell_pos: Vector2,role: int = -1, ignore_warning: bool = false):
	cells[cell_pos.x][cell_pos.y].set_as(role, ignore_warning)

func get_cell_description(cell_pos: Vector2) -> Dictionary:
	return cells[cell_pos.x][cell_pos.y].describe()

func describe() -> Dictionary:
	var res: Dictionary = {
		"name": self.name,
		"id": id,
		"cells": [],
	}
	for hor in range(3):
		res["cells"].append([])
		for ver in range(3):
			res["cells"][hor].append(cells[hor][ver].describe())
	return res

func set_as_describe(describe: Dictionary):
	if "id" in describe:
		id = describe["id"]
	if "cells" in describe:
		for hor in range(3):
			for ver in range(3):
				cells[hor][ver].set_as_describe(describe["cells"][hor][ver])
