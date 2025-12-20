extends Node

# 战斗场景系统测试
func _ready() -> void:
	print("=== 战斗场景系统完整测试开始 ===")
	
	# 等待场景完全加载
	await get_tree().create_timer(2.0).timeout
	
	# 测试各个组件
	test_battle_field_system()
	await get_tree().create_timer(1.0).timeout
	
	test_character_management()
	await get_tree().create_timer(1.0).timeout
	
	test_ui_updates()
	await get_tree().create_timer(1.0).timeout
	
	test_effect_system()
	await get_tree().create_timer(1.0).timeout
	
	print("=== 战斗场景系统测试完成 ===")

func test_battle_field_system() -> void:
	print("\n--- 测试战场系统 ---")
	
	# 查找战场节点
	var battle_field = get_tree().get_first_node_in_group("battle_field")
	if not battle_field:
		battle_field = get_node_or_null("/root/Main/BattleField")
	
	if battle_field:
		print("✓ 找到战场节点: ", battle_field.name)
		
		# 测试数据库加载器
		if battle_field.has_method("get_database_loader"):
			var db_loader = battle_field.get_database_loader()
			if db_loader:
				print("✓ 数据库加载器就绪")
			else:
				print("✗ 数据库加载器未找到")
		
		# 测试角色加载器
		if battle_field.has_method("get_character_loader"):
			var char_loader = battle_field.get_character_loader()
			if char_loader:
				print("✓ 角色加载器就绪")
			else:
				print("✗ 角色加载器未找到")
		
		# 测试焦点角色获取
		if battle_field.has_method("get_current_focus_character"):
			var focus_char = battle_field.get_current_focus_character()
			if focus_char:
				print("✓ 当前焦点角色: ", focus_char.name)
			else:
				print("! 没有焦点角色（这可能是正常的）")
		
		# 测试特效显示
		if battle_field.has_method("add_effect_display"):
			print("✓ 特效显示功能可用")
			# 测试添加特效
			battle_field.add_effect_display(Vector2(300, 200), "test")
			print("✓ 测试特效已添加")
		
	else:
		print("✗ 无法找到战场节点")

func test_character_management() -> void:
	print("\n--- 测试角色管理 ---")
	
	var battle_field = get_tree().get_first_node_in_group("battle_field")
	if not battle_field:
		return
	
	var character_manager = battle_field.get_node_or_null("2DChiefManager/CharacterManager")
	if character_manager:
		print("✓ 找到角色管理器")
		
		# 测试获取焦点角色
		var focused_char = character_manager.get_focused_character()
		if focused_char:
			print("✓ 焦点角色: ", focused_char.name)
			
			# 测试角色方法
			if focused_char.has_method("get_health"):
				var health = focused_char.get_health()
				print("✓ 角色生命值: ", health)
			
			if focused_char.has_method("get_max_health"):
				var max_health = focused_char.get_max_health()
				print("✓ 角色最大生命值: ", max_health)
			
			if focused_char.has_method("is_moving_to_target"):
				var is_moving = focused_char.is_moving_to_target()
				print("✓ 角色移动状态: ", is_moving)
			
			if focused_char.has_method("is_skill_cooldown"):
				var is_cooldown = focused_char.is_skill_cooldown()
				print("✓ 角色技能冷却状态: ", is_cooldown)
		
	else:
		print("✗ 无法找到角色管理器")

func test_ui_updates() -> void:
	print("\n--- 测试UI更新 ---")
	
	var battle_field = get_tree().get_first_node_in_group("battle_field")
	if not battle_field:
		return
	
	var player_basics = battle_field.get_node_or_null("UILayer/Control/PlayerBasics")
	if player_basics:
		print("✓ 找到玩家基础信息UI")
		
		# 测试UI脚本
		if player_basics.has_method("update_display"):
			print("✓ UI更新方法可用")
			player_basics.update_display()
			print("✓ UI更新调用成功")
		
		# 测试动态节点查找
		if player_basics.has_method("find_battle_field_node"):
			var found_battle_field = player_basics.find_battle_field_node()
			if found_battle_field:
				print("✓ 动态节点查找成功")
			else:
				print("✗ 动态节点查找失败")
		
		# 检查UI组件
		var health_bar = player_basics.get_node_or_null("HealthBar")
		if health_bar:
			print("✓ 找到血条组件: ", health_bar.name)
		
		var thumbnail = player_basics.get_node_or_null("Thumbnail")
		if thumbnail:
			print("✓ 找到缩略图组件: ", thumbnail.name)
	
	else:
		print("✗ 无法找到玩家基础信息UI")

func test_effect_system() -> void:
	print("\n--- 测试特效系统 ---")
	
	var battle_field = get_tree().get_first_node_in_group("battle_field")
	if not battle_field:
		return
	
	var effect_manager = battle_field.get_node_or_null("UILayer/Control/EffectDisplayManager")
	if effect_manager:
		print("✓ 找到特效管理器")
		
		# 测试特效显示方法
		if effect_manager.has_method("show_effect"):
			print("✓ 特效显示方法可用")
			
			# 测试不同类型的特效
			var effect_types = ["heal", "damage", "buff", "debuff"]
			for effect_type in effect_types:
				var effect_id = effect_manager.show_effect(effect_type, Vector2(300, 200))
				if effect_id >= 0:
					print("✓ 创建 ", effect_type, " 特效成功，ID: ", effect_id)
				else:
					print("✗ 创建 ", effect_type, " 特效失败")
				await get_tree().create_timer(0.2).timeout
		
		# 测试特效移除
		if effect_manager.has_method("remove_effect"):
			print("✓ 特效移除方法可用")
		
		# 测试清理所有特效
		if effect_manager.has_method("clear_all_effects"):
			print("✓ 清理所有特效方法可用")
	
	else:
		print("✗ 无法找到特效管理器")

# 辅助函数：查找节点
func get_node_by_path(path: String) -> Node:
	return get_node_or_null(path)

# 辅助函数：检查方法是否存在
func has_method_safe(node: Node, method_name: String) -> bool:
	if not node:
		return false
	return node.has_method(method_name)