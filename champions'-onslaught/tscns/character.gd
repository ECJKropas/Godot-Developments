extends Node2D

@export var type:String = "default"
@export var summon_id:int

@export var max_health:int = 100
@export var health:float = 100
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

# 安全获取当前场景的函数
func get_current_scene():
	await tree_entered
	if current_scene == null and is_inside_tree():
		current_scene = get_tree().current_scene
	return current_scene

var velocity = Vector2.ZERO
var target_velocity = Vector2.ZERO

@onready var effect_manager = get_node("EffectManager")
@onready var skill_manager = get_node("EffectManager")
@onready var mechanics_manager = get_node("MechanicsManager")

var damage_buffs:Dictionary={
	"Default":{
		"val":0.5,
		"op":"mul"
	}
}

func suffer_damage(ini_damage:float):
	var res_damage=ini_damage
	for i in damage_buffs.values():
		if i["op"]=="mul":
			res_damage*=i["val"]
		if i["op"]=="div":
			res_damage/=i["val"]
	for i in damage_buffs.values():
		if i["op"]=="add":
			res_damage+=i["val"]
		if i["op"]=="sub":
			res_damage-=i["val"]
	res_damage=max(res_damage,0)
	res_damage=min(res_damage,health+10)
	health-=res_damage
	return res_damage


var attrs = {
	"Lust":0,
	"Gluttony":0,
	"Greed":0,
	"Sloth":0,
	"Wrath":0,
	"Envy":0,
	"Pride":0
}


var dead:bool = false
var hidden_time = 1

func _process(delta: float) -> void:
	HealthBar.set_health(health,max_health)
	
	# Smooth velocity interpolation
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	# Apply friction when no input
	if target_velocity.length() == 0:
		velocity = velocity * friction
	
	# Apply movement
	position += velocity * delta
	
	if health<=0 and !dead:
		dead=true
		var dying_manager = load("res://die.tscn").instantiate()
		current_scene.add_child(dying_manager)
		dying_manager.die_init(self,1)
		await dying_manager.dead_process_finished
	
	



	

var status = ""
var initiallized = false

func get_camp() -> String:
	return camp

# 效果管理相关方法
func add_effect(effect_name: String) -> void:
	if effect_manager != null:
		effect_manager.add_effect(effect_name)

func remove_effect(effect_name: String) -> void:
	if effect_manager != null:
		effect_manager.remove_effect(effect_name)

func has_effect(effect_name: String) -> bool:
	if effect_manager != null:
		return effect_manager.has_effect(effect_name)
	return false

func get_effects() -> Array:
	if effect_manager != null:
		return effect_manager.get_effects()
	return []

func clear_all_effects() -> void:
	if effect_manager != null:
		effect_manager.clear_all_effects()



func init_role(configList: Dictionary) -> void:
	initiallized = false
	
	var scene = await get_current_scene()
	if scene==null:
		print("初始化失败")
		return
	
	self.type = configList["type"]
	self.summon_id = configList["summon_id"]
	self.max_health = configList["health"]
	self.original_speed = configList["original_speed"]
	self.camp = configList["camp"]
	
	self.health = max_health
	
	effect_manager = get_node("EffectManager")
	# 设置效果列表到效果管理器
	if effect_manager != null:
		effect_manager.set_effects(configList["effects"])
	else:
		print("警告：EffectManager节点未找到，无法设置效果")
	
	skill_manager = get_node("SkillManager")
	# 设置效果列表到效果管理器
	if skill_manager != null:
		skill_manager.load_funcs(configList["skills"])
	else:
		print("警告：SkillManager节点未找到，无法设置效果")
	
	mechanics_manager = get_node("MechanicsManager")
	# 设置效果列表到效果管理器
	if mechanics_manager != null:
		mechanics_manager.set_mechanicss(configList["mechanics"])
	else:
		print("警告：MechanicsManager节点未找到，无法设置效果")

	for key in configList.keys():
		if key in attrs.keys():
			attrs[key] = configList[key]
	
	Sprite = get_node("Sprite2D")
	if "img" in configList.keys():
		status = "加载图像中……"
		var pic_texture = load(configList["img"])
		if pic_texture:
			Sprite.texture = pic_texture
		else:
			print("图片加载失败 At ",configList["img"])
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
	
	# Set target velocity based on input
	if movement_vector.length() > 0:
		movement_vector = movement_vector.normalized()
		target_velocity = movement_vector * original_speed * speed_amplifier * 100
	else:
		target_velocity = Vector2.ZERO


func _on_effect_manager_ready() -> void:
	pass # Replace with function body.
