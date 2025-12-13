extends Node2D

var character_scene = preload("res://tscns/character.tscn")
var card_suit_data = null

# 数据库变量
var effects_database = []
var effects_func_database = {}  # Dictionary[Node]
var skills_database = []
var skills_mapping = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 加载卡牌数据
	load_card_suit_data()
	
	# 加载effects和skills数据库
	load_effects_database()
	load_skills_database()
	
	# 创建friend阵营的character
	create_friend_character()
	create_enemy_character()



func load_card_suit_data() -> void:
	# 读取defaultCardSuit.json文件
	var file = FileAccess.open("res://defaultCardSuit.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			card_suit_data = json.get_data()
		else:
			print("JSON解析错误: ", json.get_error_message())
	else:
		print("无法打开defaultCardSuit.json文件")

func load_effects_database() -> void:
	# 读取all_effects.json文件
	var file = FileAccess.open("res://all_effects.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			effects_database = json.get_data()
			
			# 加载effects_func_database
			for effect_data in effects_database:
				if effect_data.has("type") and effect_data.has("scr"):
					var effect_type = effect_data["type"]
					var scr_path = effect_data["scr"]
					
					# 创建脚本实例
					var effect_script = load(scr_path)
					if effect_script:
						var effect_instance = effect_script.new()
						effects_func_database[effect_type] = effect_instance
						print("已加载effect: ", effect_type, " 从 ", scr_path)
					else:
						print("无法加载effect脚本: ", scr_path)
			
			print("成功加载 ", effects_database.size(), " 个effects")
		else:
			print("effects JSON解析错误: ", json.get_error_message())
	else:
		print("无法打开all_effects.json文件")

func load_skills_database() -> void:
	# 读取all_skills.json文件
	var file = FileAccess.open("res://all_skills.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			skills_database = json.get_data()
			for skill in skills_database:
				skills_mapping[skill["name"]]=skill
			print("成功加载 ", skills_database.size(), " 个skills")
		else:
			print("skills JSON解析错误: ", json.get_error_message())
	else:
		print("无法打开all_skills.json文件")

func create_friend_character() -> void:
	if card_suit_data == null or not card_suit_data.has("heros") or card_suit_data["heros"].size() == 0:
		print("没有可用的英雄数据")
		return
	
	# 获取第一个英雄数据
	var hero_data = card_suit_data["heros"][0]
	
	# 创建character配置
	var character_config = {
		"type": hero_data["type"],
		"summon_id": 1,  # 生成唯一ID
		"health": hero_data["health"],
		"original_speed": hero_data["original_speed"],
		"camp": "friend",  # 设置为friend阵营
		"effects": hero_data["effects"],
		"skills": hero_data["skills"]
	}
	
	# 实例化character场景
	var character_instance = character_scene.instantiate()
	
	# 设置位置（可以根据需要调整）
	character_instance.position = Vector2(400, 300)
	
	# 初始化角色
	character_instance.init_role(character_config)
	character_instance.focused=true;
	
	# 添加到场景中
	add_child(character_instance)
	
	print("创建了friend阵营的角色: ", hero_data["name"])
	
func create_enemy_character() -> void:
	if card_suit_data == null or not card_suit_data.has("heros") or card_suit_data["heros"].size() == 0:
		print("没有可用的英雄数据")
		return
	
	# 获取第一个英雄数据
	var hero_data = card_suit_data["heros"][1]
	
	# 创建character配置
	var character_config = hero_data
	character_config["summon_id"] = 2
	character_config["camp"] = "enemy"
	
	# 实例化character场景
	var character_instance = character_scene.instantiate()
	
	# 设置位置（可以根据需要调整）
	character_instance.position = Vector2(200, 300)
	# 初始化角色
	character_instance.init_role(character_config)
	# 添加到场景中
	add_child(character_instance)
	
	
	print("创建了enemy阵营的角色: ", hero_data["name"])

# 获取我方英雄
func get_our_hero(camp: String) -> Array[Node2D]:
	var our_heroes:Array[Node2D] = []
	for child in get_children():
		if child is Node2D and child.has_method("get_camp") and child.get_camp() == camp:
			our_heroes.append(child)
	return our_heroes

# 获取敌方英雄
func get_other_hero(camp: String) -> Array[Node2D]:
	var other_heroes:Array[Node2D] = []
	for child in get_children():
		if child is Node2D and child.has_method("get_camp") and child.get_camp() != camp:
			other_heroes.append(child)
	return other_heroes

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
