extends Node

# 数据库变量
var effects_database = []
var effects_func_database = { }  # Dictionary[Node]
var skills_database = []
var skills_mapping = { }
var mechanics_database = []
var mechanics_func_database = { }  # Dictionary[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 加载effects、skills和mechanics数据库
	load_effects_database()
	load_skills_database()
	load_mechanics_database()

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
				skills_mapping[skill["type"]] = skill
			print("成功加载 ", skills_database.size(), " 个skills")
		else:
			print("skills JSON解析错误: ", json.get_error_message())
	else:
		print("无法打开all_skills.json文件")

func load_mechanics_database() -> void:
	# 读取all_mechanics.json文件
	var file = FileAccess.open("res://all_mechanics.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_text)
		if parse_result == OK:
			mechanics_database = json.get_data()

			# 加载mechanics_func_database
			for mechanics_data in mechanics_database:
				if mechanics_data.has("type") and mechanics_data.has("scr"):
					var mechanics_type = mechanics_data["type"]
					var scr_path = mechanics_data["scr"]

					# 创建脚本实例
					var mechanics_script = load(scr_path)
					if mechanics_script:
						var mechanics_instance = mechanics_script.new()
						mechanics_func_database[mechanics_type] = mechanics_instance
						print("已加载mechanics: ", mechanics_type, " 从 ", scr_path)
					else:
						print("无法加载mechanics脚本: ", scr_path)

			print("成功加载 ", mechanics_database.size(), " 个mechanics")
		else:
			print("mechanics JSON解析错误: ", json.get_error_message())
	else:
		print("无法打开all_mechanics.json文件")
