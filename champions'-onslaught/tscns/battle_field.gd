extends Node2D

@onready var database_loader = $DatabaseLoader
@onready var character_loader = $CharacterLoader
@onready var character_manager = $"2DChiefManager/CharacterManager"
@onready var log_place = $"UILayer/Control/Logboard/LogPlace"

var current_focus_character = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 等待数据库加载完成
	await get_tree().create_timer(0.1).timeout
	
	# 创建角色
	create_initial_characters()
	
	# 设置初始焦点角色
	set_initial_focus()

func create_initial_characters() -> void:
	# 创建我方第一个角色
	var my_first_char_data = character_loader.get_first_my_character_data()
	if my_first_char_data:
		var my_character = character_loader.create_character(my_first_char_data, "friend", Vector2(400, 300))
		if my_character:
			character_manager.add_character(my_character)
			log_message("创建了我方角色: " + my_first_char_data.get("name", "Unknown"))
	
	# 创建敌方第一个角色
	var enemy_first_char_data = character_loader.get_first_enemy_character_data()
	if enemy_first_char_data:
		var enemy_character = character_loader.create_character(enemy_first_char_data, "enemy", Vector2(200, 300))
		if enemy_character:
			character_manager.add_character(enemy_character)
			log_message("创建了敌方角色: " + enemy_first_char_data.get("name", "Unknown"))

func set_initial_focus() -> void:
	# 设置第一个我方角色为焦点
	var friendly_characters = character_manager.get_all_friendly_characters()
	if friendly_characters.size() > 0:
		var first_friendly = friendly_characters[0]
		character_manager.set_focused_character(first_friendly)
		current_focus_character = first_friendly
		log_message("设置焦点角色: " + first_friendly.get_character_name() if first_friendly.has_method("get_character_name") else "Unknown")

func get_current_focus_character():
	return current_focus_character

func set_focus_character(character):
	# 清除之前的焦点
	if current_focus_character and current_focus_character.has_method("set_focused"):
		current_focus_character.set_focused(false)
		# 清除角色的焦点目标
		if current_focus_character.has_method("set_focus_character"):
			current_focus_character.set_focus_character(null)
	
	# 设置新的焦点
	current_focus_character = character
	if current_focus_character and current_focus_character.has_method("set_focused"):
		current_focus_character.set_focused(true)
		log_message("切换焦点角色: " + current_focus_character.get_character_name() if current_focus_character.has_method("get_character_name") else "Unknown")
		
		# 设置角色的焦点目标（如果有当前锁定目标）
		var chief_manager = $"2DChiefManager"
		if chief_manager and chief_manager.has_method("get_current_focus_target"):
			var target = chief_manager.get_current_focus_target()
			if target and current_focus_character.has_method("set_focus_character"):
				current_focus_character.set_focus_character(target)

func add_effect_display(position: Vector2, effect_type: String) -> void:
	# 获取特效显示管理器
	var effect_display_manager = $"UILayer/Control/EffectDisplayManager"
	if effect_display_manager and effect_display_manager.has_method("add_effect"):
		effect_display_manager.add_effect(position, effect_type)
		log_message("添加特效: " + effect_type)
	else:
		print("警告：无法找到特效显示管理器或add_effect方法")

func log_message(message: String) -> void:
	if log_place and log_place.has_method("add_log"):
		log_place.add_log(message)
	else:
		print("Log: ", message)

func get_database_loader():
	return database_loader

func get_character_loader():
	return character_loader

# 测试特效显示系统的方法
func test_effect_display(effect_type: String, test_position: Vector2 = Vector2(300, 200)) -> void:
	print("测试特效显示: ", effect_type, " 位置: ", test_position)
	add_effect_display(test_position, effect_type)
	
# 测试所有特效类型
func test_all_effects() -> void:
	var test_position = Vector2(300, 200)
	var effect_types = ["heal", "damage", "buff", "debuff", "skill_hit"]
	
	for i in range(effect_types.size()):
		var pos = test_position + Vector2(i * 80, 0)
		test_effect_display(effect_types[i], pos)
		await get_tree().create_timer(0.5).timeout
