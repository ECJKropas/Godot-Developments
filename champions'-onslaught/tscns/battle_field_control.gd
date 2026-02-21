extends Control

@onready var effect_display_manager = find_effect_display_manager()
@onready var player_basics = find_player_basics()
@onready var battle_field = get_node("../..")  # 获取BattleField节点

func find_effect_display_manager():
	if get_node_or_null("EffectDisplayManager"):
		return get_node("EffectDisplayManager")

	# 尝试兄弟节点
	var parent = get_parent()
	if parent and parent.has_node("EffectDisplayManager"):
		return parent.get_node("EffectDisplayManager")
	
	# 尝试完整路径
	var full_path = get_node_or_null("../EffectDisplayManager")
	if full_path:
		return full_path
	
	# 尝试递归查找
	return find_node_in_children(get_parent(), "EffectDisplayManager")

func find_player_basics():
	if get_node_or_null("PlayerBasics"):
		return get_node("PlayerBasics")

	# 尝试兄弟节点
	var parent = get_parent()
	if parent and parent.has_node("PlayerBasics"):
		return parent.get_node("PlayerBasics")
	
	# 尝试完整路径
	var full_path = get_node_or_null("../PlayerBasics")
	if full_path:
		return full_path
	
	# 尝试递归查找
	return find_node_in_children(get_parent(), "PlayerBasics")

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
	# 检查特效显示管理器是否存在
	if effect_display_manager:
		if effect_display_manager.has_method("initialize"):
			effect_display_manager.initialize()
		else:
			print("警告：EffectDisplayManager没有initialize方法")
	else:
		print("错误：未找到EffectDisplayManager节点")
	
	# 检查玩家基础信息面板
	if not player_basics:
		print("警告：未找到PlayerBasics节点")

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
