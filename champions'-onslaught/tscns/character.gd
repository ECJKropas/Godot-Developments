extends Node2D

@export var type:String = "default"
@export var summon_id:int

@export var health:int = 100
@export var original_speed:int = 5
@export var speed_amplifier:float = 1.00
@export var acceleration:float = 15.0
@export var friction:float = 0.85

@export var target:Node2D = null
@export var camp:String = "default"

@export var focused:bool = false

@onready var HealthBar:ProgressBar = get_node("HealthBar")
@onready var Sprite:Sprite2D = get_node("Sprite2D")
var current_scene = null

var velocity = Vector2.ZERO
var target_velocity = Vector2.ZERO

var effects_list:Array = []
var effect_dic:Dictionary = {}

# 时间戳记录器
var timer:float = 0.0

var skills_list:Array
var skills_funcs:Array

var attrs = {
	"Lust":0,
	"Gluttony":0,
	"Greed":0,
	"Sloth":0,
	"Wrath":0,
	"Envy":0,
	"Pride":0
}

var priority_key_list:String="QERTYUIOPFGHJKLZXCVBNM"

func _process(delta: float) -> void:
	# 更新时间戳
	timer += delta
	
	HealthBar.value=health
	
	# Smooth velocity interpolation
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	# Apply friction when no input
	if target_velocity.length() == 0:
		velocity = velocity * friction
	
	# Apply movement
	position += velocity * delta
	
	# 处理效果列表
	process_effects()

# 处理效果逻辑
func process_effects() -> void:
	var scene = get_current_scene()
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
			if scene.has("effects_func_database") and scene.effects_func_database.has(effect):
				print("应用新效果: ", effect, " 初始时间: ", timer)
				scene.effects_func_database[effect].apply_effect(self)
		else:
			# 效果已存在，检查时间
			var effect_start_time = effect_dic[effect]
			# 从效果数据库中获取效果属性
			if scene.has("effects_func_database") and scene.effects_func_database.has(effect) and scene.has("effects_database"):
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
								effect_data.apply_effect(self)
						else:
							# 时间到了，结束效果
							print("效果结束: ", effect)
							if effect_data.has_method("effect_end"):
								effect_data.effect_end(self)
							# 标记为待移除
							effects_to_remove.append(effect)
					else:
						# 没有持续时间，认为是永久效果或需要手动移除
						if effect_property.has("effect_type") and effect_property["effect_type"] == "constant":
							effect_data.apply_effect(self)
	
	# 移除过期效果
	for effect in effects_to_remove:
		print("移除过期效果: ", effect, " 初始时间: ", effect_dic[effect])
		effect_dic.erase(effect)
		var index = effects_list.find(effect)
		if index != -1:
			effects_list.remove_at(index)


	

var status = ""
var initiallized = false

func get_camp() -> String:
	return camp

# 安全获取当前场景的函数
func get_current_scene():
	if current_scene == null and is_inside_tree():
		current_scene = get_tree().current_scene
	return current_scene

func init_role(configList: Dictionary) -> void:
	initiallized = false
	
	await tree_entered
	var scene = get_current_scene()
	if scene==null:
		print("初始化失败")
		return
	
	self.type = configList["type"]
	self.summon_id = configList["summon_id"]
	self.health = configList["health"]
	self.original_speed = configList["original_speed"]
	self.camp = configList["camp"]
	self.effects_list = configList["effects"]
	print("已完成部分加载",scene==null)

	
	if scene != null and scene.has("skills_database"):
		status = "加载技能中……"
		print(status)
		skills_list = configList["skills"]
		for skill in skills_list:
			var skill_data = scene.skills_mapping[skill]
			status = "加载技能中…… " + skill_data["name"]
			print(status)
			var skill_script = load(skill_data["scr"])
			var skill_instance = skill_script.new()
			skills_funcs.append(skill_instance)



	for key in configList.keys():
		if key in attrs.keys():
			attrs[key] = configList[key]
	
	if "img" in configList.keys():
		status = "加载图像中……"
		Sprite.texture = load(configList["img"])
	initiallized = true

func _input(event: InputEvent) -> void:
	if not focused:
		return
	
	var movement_vector = Vector2.ZERO
	
	if event.is_action_pressed("ui_left") or Input.is_action_pressed("ui_left"):
		movement_vector.x -= 1
	if event.is_action_pressed("ui_right") or Input.is_action_pressed("ui_right"):
		movement_vector.x += 1
	if event.is_action_pressed("ui_up") or Input.is_action_pressed("ui_up"):
		movement_vector.y -= 1
	if event.is_action_pressed("ui_down") or Input.is_action_pressed("ui_down"):
		movement_vector.y += 1
	
	# Check for WASD keys
	if event.is_action_pressed("move_left") or Input.is_action_pressed("move_left"):
		movement_vector.x -= 1
	if event.is_action_pressed("move_right") or Input.is_action_pressed("move_right"):
		movement_vector.x += 1
	if event.is_action_pressed("move_up") or Input.is_action_pressed("move_up"):
		movement_vector.y -= 1
	if event.is_action_pressed("move_down") or Input.is_action_pressed("move_down"):
		movement_vector.y += 1

	if event is InputEventKey and event.pressed and not event.echo:
		# 判断 keycode 是否在 KEY_A ~ KEY_Z 范围内
		if event.keycode >= KEY_A and event.keycode <= KEY_Z:
			# 转换为字母字符串（如 KEY_A → "A"，KEY_B → "B"）
			var letter = String.chr(ord("A") + (event.keycode - KEY_A))
			print("按下了字母键：", letter)
			for i in range(priority_key_list.length()):
				var key = priority_key_list[i]
				if letter == key:
					if i < skills_list.size():
							print("使用了技能：", skills_list[i])
							var scene = get_current_scene()
							if scene != null and scene != self:
								skills_funcs[i].show_skill(self, scene.get_our_hero(self.camp), scene.get_other_hero(self.camp))
					break
	
	# Set target velocity based on input
	if movement_vector.length() > 0:
		movement_vector = movement_vector.normalized()
		target_velocity = movement_vector * original_speed * speed_amplifier * 100
	else:
		target_velocity = Vector2.ZERO
