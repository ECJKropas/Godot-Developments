extends Control

@onready var effect_display_manager = find_effect_display_manager()
@onready var player_basics = $PlayerBasics
@onready var battle_field = get_node("..")  # 获取BattleField节点

func find_effect_display_manager():
	# 尝试直接子节点
	var direct_child = $EffectDisplayManager if has_node("EffectDisplayManager") else null
	if direct_child:
		return direct_child
	
	# 尝试完整路径
	var full_path = get_node_or_null("EffectDisplayManager")
	if full_path:
		return full_path
	
	# 尝试递归查找
	return find_node_in_children(self, "EffectDisplayManager")

func find_node_in_children(node, target_name):
	for child in node.get_children():
		if child.name == target_name:
			return child
		var result = find_node_in_children(child, target_name)
		if result:
			return result
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("战场控制UI初始化开始...")
	
	# 打印当前节点的子节点信息
	print("当前节点的子节点:")
	for child in get_children():
		print("  - ", child.name, " (类型: ", child.get_class(), ")")
		if child.name == "EffectDisplayManager":
			print("    EffectDisplayManager找到，脚本: ", child.get_script() if child.get_script() else "无脚本")
	
	# 检查特效显示管理器是否存在
	if effect_display_manager:
		print("找到EffectDisplayManager节点")
		print("EffectDisplayManager类型: ", effect_display_manager.get_class())
		print("EffectDisplayManager脚本: ", effect_display_manager.get_script() if effect_display_manager.get_script() else "无脚本")
		
		if effect_display_manager.has_method("initialize"):
			effect_display_manager.initialize()
			print("EffectDisplayManager初始化完成")
		else:
			print("警告：EffectDisplayManager没有initialize方法")
			print("可用方法: ", effect_display_manager.get_method_list())
	else:
		print("错误：未找到EffectDisplayManager节点")
	
	# 检查玩家基础信息面板
	if player_basics:
		print("找到PlayerBasics节点")
	else:
		print("警告：未找到PlayerBasics节点")
	
	print("战场控制UI初始化完成")

func _process(delta: float) -> void:
	# 更新UI状态
	update_ui()

func update_ui() -> void:
	# 这里可以添加各种UI更新逻辑
	pass

func show_effect(effect_type: String, position: Vector2, target = null) -> void:
	if effect_display_manager:
		effect_display_manager.show_effect(effect_type, position, target)

func hide_effect(effect_id) -> void:
	if effect_display_manager:
		effect_display_manager.hide_effect(effect_id)

func get_player_basics():
	return player_basics

func get_effect_display_manager():
	return effect_display_manager
