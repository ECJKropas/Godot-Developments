extends Node2D

# 机制管理器 - 负责处理角色的所有机制逻辑

var mechanics_list: Array = []
var parent_character: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 获取父角色节点
	parent_character = get_parent()
	if parent_character == null:
		print("错误：MechanicsManager没有找到父角色节点")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# 处理机制列表
	process_mechanicss()

# 处理机制逻辑
func process_mechanicss() -> void:
	if parent_character == null:
		return
		
	var scene = await get_current_scene()
	if scene == null:
		return
	
	
	# 检查mechanicss_list中的每一项
	for mechanics in mechanics_list:
		scene.mechanics_func_database[mechanics].check_and_apply(parent_character)
		

# 安全获取当前场景的函数
func get_current_scene():
	await get_tree().process_frame
	return get_tree().current_scene

# 添加机制到列表
func add_mechanics(mechanics_name: String) -> void:
	if not mechanics_name in mechanics_list:
		mechanics_list.append(mechanics_name)
		print("添加机制: ", mechanics_name)

# 移除机制
func remove_mechanics(mechanics_name: String) -> void:
	if mechanics_name in mechanics_list:
		var index = mechanics_list.find(mechanics_name)
		if index != -1:
			mechanics_list.remove_at(index)
		print("移除机制: ", mechanics_name)

# 获取当前机制列表
func get_mechanicss() -> Array:
	return mechanics_list.duplicate()

# 设置机制列表（用于初始化）
func set_mechanicss(mechanicss: Array) -> void:
	mechanics_list = mechanicss.duplicate()
	print("设置机制列表: ", mechanics_list)

# 检查是否有指定机制
func has_mechanics(mechanics_name: String) -> bool:
	return mechanics_name in mechanics_list

# 清除所有机制
func clear_all_mechanicss() -> void:
	for mechanics in mechanics_list:
		remove_mechanics(mechanics)
	mechanics_list.clear()
	print("清除所有机制")
