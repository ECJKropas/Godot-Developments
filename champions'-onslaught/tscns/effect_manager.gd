extends Node2D

# 效果管理器 - 负责处理角色的所有效果逻辑

var effects_list: Array = []
var effect_dic: Dictionary = {}
var timer: float = 0.0
var parent_character: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 获取父角色节点
	parent_character = get_parent()
	if parent_character == null:
		print("错误：EffectManager没有找到父角色节点")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 更新时间戳
	timer += delta
	
	# 处理效果列表
	process_effects(delta)

# 处理效果逻辑
func process_effects(delta: float) -> void:
	if parent_character == null:
		return
		
	var scene = await get_current_scene()
	if scene == null:
		return
		
	# 用于存储需要移除的效果
	var effects_to_remove = []
	
	# 检查effects_list中的每一项
	for effect in effects_list:
		# 如果效果不在effect_dic中，添加新效果
		if not effect in effect_dic:
			effect_dic[effect] = timer  # 记录效果初始时间
			# 应用效果
			if scene!=self and scene.effects_func_database.has(effect):
				print("应用新效果: ", effect, " 初始时间: ", timer)
				scene.effects_func_database[effect].apply_effect(parent_character)
		else:
			# 效果已存在，检查时间
			var effect_start_time = effect_dic[effect]
			# 从效果数据库中获取效果属性
			if scene!=self and scene.effects_func_database.has(effect):
				var effect_data = scene.effects_func_database[effect]
				var effect_property = null
				
				# 在效果数据库中查找对应的效果配置
				for effect_config in scene.effects_database:
					if effect_config.has("type") and effect_config["type"] == effect:
						effect_property = effect_config
						break
				
				if effect_property != null:
					# 检查是否有持续时间属性
					if effect_property.has("duration"):
						var duration = effect_property["duration"]
						if timer - effect_start_time < duration:
							# 时间未到，继续应用效果
							if effect_property.has("effect_type") and effect_property["effect_type"] == "constant":
								effect_data.apply_effect(parent_character,delta)
						else:
							# 时间到了，结束效果
							print("效果结束: ", effect)
							if effect_data.has_method("effect_end"):
								effect_data.effect_end(parent_character)
							# 标记为待移除
							effects_to_remove.append(effect)
					else:
						# 没有持续时间，认为是永久效果或需要手动移除
						if effect_property.has("effect_type") and effect_property["effect_type"] == "constant":
							effect_data.apply_effect(parent_character)
	
	# 移除过期效果
	for effect in effects_to_remove:
		print("移除过期效果: ", effect, " 初始时间: ", effect_dic[effect])
		effect_dic.erase(effect)
		var index = effects_list.find(effect)
		if index != -1:
			effects_list.remove_at(index)

# 安全获取当前场景的函数
func get_current_scene():
	await get_tree().process_frame
	return get_tree().current_scene

# 添加效果到列表
func add_effect(effect_name: String) -> void:
	if not effect_name in effects_list:
		effects_list.append(effect_name)
		print("添加效果: ", effect_name)

# 移除效果
func remove_effect(effect_name: String) -> void:
	if effect_name in effects_list:
		var index = effects_list.find(effect_name)
		if index != -1:
			effects_list.remove_at(index)
		
	if effect_name in effect_dic:
		var scene = await get_current_scene()
		if scene != null and scene.has("effects_func_database") and scene.effects_func_database.has(effect_name):
			var effect_data = scene.effects_func_database[effect_name]
			if effect_data.has_method("effect_end"):
				effect_data.effect_end(parent_character)
		effect_dic.erase(effect_name)
		print("移除效果: ", effect_name)

# 获取当前效果列表
func get_effects() -> Array:
	return effects_list.duplicate()

# 设置效果列表（用于初始化）
func set_effects(effects: Array) -> void:
	effects_list = effects.duplicate()
	print("设置效果列表: ", effects_list)

# 检查是否有指定效果
func has_effect(effect_name: String) -> bool:
	return effect_name in effects_list

# 清除所有效果
func clear_all_effects() -> void:
	for effect in effects_list:
		remove_effect(effect)
	effects_list.clear()
	effect_dic.clear()
	print("清除所有效果")
