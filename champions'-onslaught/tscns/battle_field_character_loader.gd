extends Node

var character_scene = preload("res://tscns/character.tscn")
var my_characters_data = null
var enemy_characters_data = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 加载角色数据
	load_my_characters_data()
	load_enemy_characters_data()

func load_my_characters_data() -> void:
	# 检查user://my_characters.json是否存在
	var user_file_path = "user://my_characters.json"
	var default_file_path = "res://defaultCardSuit.json"
	
	# 检查默认文件是否存在
	if not FileAccess.file_exists(default_file_path):
		print("警告：默认文件不存在: ", default_file_path)
		my_characters_data = {"heros": []}
		return
	
	# 如果user文件不存在，从默认文件复制
	if not FileAccess.file_exists(user_file_path):
		print("user://my_characters.json不存在，从默认文件复制...")
		copy_file(default_file_path, user_file_path)
	
	# 加载用户角色数据
	my_characters_data = load_json_file(user_file_path)
	if my_characters_data:
		print("成功加载用户角色数据，共 ", my_characters_data.get("heros", []).size(), " 个角色")
	else:
		print("加载用户角色数据失败，使用空数据")
		my_characters_data = {"heros": []}

func load_enemy_characters_data() -> void:
	# 检查user://enemy_characters.json是否存在
	var user_file_path = "user://enemy_characters.json"
	var default_file_path = "res://defaultCardSuit.json"
	
	# 检查默认文件是否存在
	if not FileAccess.file_exists(default_file_path):
		print("警告：默认文件不存在: ", default_file_path)
		enemy_characters_data = {"heros": []}
		return
	
	# 如果user文件不存在，从默认文件复制
	if not FileAccess.file_exists(user_file_path):
		print("user://enemy_characters.json不存在，从默认文件复制...")
		copy_file(default_file_path, user_file_path)
	
	# 加载敌人角色数据
	enemy_characters_data = load_json_file(user_file_path)
	if enemy_characters_data:
		print("成功加载敌人角色数据，共 ", enemy_characters_data.get("heros", []).size(), " 个角色")
	else:
		print("加载敌人角色数据失败，使用空数据")
		enemy_characters_data = {"heros": []}

func copy_file(source_path: String, dest_path: String) -> void:
	var source_file = FileAccess.open(source_path, FileAccess.READ)
	if not source_file:
		print("无法打开源文件: ", source_path)
		return
	
	var content = source_file.get_as_text()
	source_file.close()
	
	var dest_file = FileAccess.open(dest_path, FileAccess.WRITE)
	if not dest_file:
		print("无法创建目标文件: ", dest_path)
		return
	
	dest_file.store_string(content)
	dest_file.close()
	print("文件复制成功: ", source_path, " -> ", dest_path)

func load_json_file(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			return json.get_data()
		else:
			print("JSON解析错误: ", json.get_error_message(), " 文件: ", file_path)
			return {}
	else:
		print("无法打开文件: ", file_path)
		return {}

func get_my_characters_data() -> Dictionary:
	return my_characters_data

func get_enemy_characters_data() -> Dictionary:
	return enemy_characters_data

func create_character(character_data: Dictionary, camp: String, position: Vector2) -> Node:
	if not character_data:
		print("角色数据为空")
		return null
	
	# 检查角色场景是否有效
	if not character_scene:
		print("角色场景预加载失败")
		return null
	
	# 创建角色配置
	var character_config = character_data.duplicate()
	character_config["summon_id"] = 2
	character_config["camp"] = camp
	
	# 实例化角色场景
	var character_instance = character_scene.instantiate()
	if not character_instance:
		print("角色实例化失败")
		return null
	
	# 设置位置
	character_instance.position = position
	
	# 检查是否有init_role方法
	if character_instance.has_method("init_role"):
		character_instance.init_role(character_config)
	else:
		print("警告：角色实例没有init_role方法，使用默认初始化")
		# 尝试设置基本属性
		if character_instance.has_method("set_name") and character_data.has("name"):
			character_instance.set_name(character_data["name"])
	
	print("创建了角色: ", character_data.get("name", "Unknown"), " 阵营: ", camp)
	return character_instance

func get_first_my_character_data() -> Dictionary:
	if my_characters_data and my_characters_data.has("heros") and my_characters_data["heros"].size() > 0:
		return my_characters_data["heros"][0]
	return {}

func get_first_enemy_character_data() -> Dictionary:
	if enemy_characters_data and enemy_characters_data.has("heros") and enemy_characters_data["heros"].size() > 0:
		return enemy_characters_data["heros"][0]
	return {}
