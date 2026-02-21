extends Node2D

@export var type: String = "default"
@export var summon_id: int

@export var max_health: int = 100
@export var health: float = 100
@export var original_speed: int = 5
@export var speed_amplifier: float = 1.00
# Movement properties moved to CharacterBody2D
@onready var character_body = get_node("CharacterBody2D")

var texture_path

# Speed control methods
func set_original_speed(new_speed: int) -> void:
	original_speed = new_speed
	if character_body:
		character_body.set_speed_properties(original_speed, speed_amplifier)

func set_speed_amplifier(new_amplifier: float) -> void:
	speed_amplifier = new_amplifier
	if character_body:
		character_body.set_speed_properties(original_speed, speed_amplifier)

func multiply_speed_amplifier(new_amplifier: float) -> void:
	speed_amplifier *= new_amplifier
	if character_body:
		character_body.set_speed_properties(original_speed, speed_amplifier)

func get_speed_properties() -> Dictionary:
	return {
		"original_speed": original_speed,
		"speed_amplifier": speed_amplifier
	}

@export var target: Node2D = null
@export var camp: String = "default"

@export var focused: bool = false

@onready var HealthBar: ProgressBar = get_node("HealthBar")
@onready var Sprite: Sprite2D = get_node("Sprite2D")

var current_scene = null


# 安全获取当前场景的函数
func get_current_scene():
	await tree_entered
	if current_scene == null and is_inside_tree():
		current_scene = get_tree().current_scene
	return current_scene

# Movement variables moved to CharacterBody2D

@onready var effect_manager = get_node("EffectManager")
@onready var skill_manager = get_node("EffectManager")
@onready var mechanics_manager = get_node("MechanicsManager")

var damage_buffs: Dictionary = {
	"Default": {
		"val": 0.5,
		"op": "mul"
	}
}


func suffer_damage(ini_damage: float):
	var res_damage = ini_damage
	for i in damage_buffs.values():
		if i["op"] == "mul":
			res_damage *= i["val"]
		if i["op"] == "div":
			res_damage /= i["val"]
	for i in damage_buffs.values():
		if i["op"] == "add":
			res_damage += i["val"]
		if i["op"] == "sub":
			res_damage -= i["val"]
	res_damage = max(res_damage, 0)
	res_damage = min(res_damage, health + 10)
	health -= res_damage
	
	# 显示伤害特效
	if res_damage > 0:
		var battle_field = get_parent()
		if battle_field and battle_field.has_method("add_effect_display"):
			battle_field.add_effect_display(global_position, "damage")
	
	return res_damage

func heal(amount: float) -> void:
	var old_health = health
	health = min(health + amount, max_health)
	var healed_amount = health - old_health
	
	# 更新血条显示
	if HealthBar:
		HealthBar.set_health(health, max_health)
	
	# 显示治疗特效
	if healed_amount > 0:
		var battle_field = get_parent()
		if battle_field and battle_field.has_method("add_effect_display"):
			battle_field.add_effect_display(global_position, "heal")
		print("角色 ", name, " 恢复了 ", healed_amount, " 点生命值")

var attrs = {
	"Lust": 0,
	"Gluttony": 0,
	"Greed": 0,
	"Sloth": 0,
	"Wrath": 0,
	"Envy": 0,
	"Pride": 0
}

var dead: bool = false
var hidden_time = 1


func _process(delta: float) -> void:
	HealthBar.set_health(health, max_health)
	
	# 处理技能系统
	_process_skill_system(delta)

	# Update CharacterBody2D focus state
	if character_body:
		character_body.set_focus(focused)

	if health <= 0 and !dead:
		dead = true
		var dying_manager = load("res://die.tscn").instantiate()
		current_scene.add_child(dying_manager)
		dying_manager.die_init(self, 1)
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
	if scene == null:
		print("初始化失败")
		return

	self.type = configList["type"]
	self.summon_id = configList["summon_id"]
	self.max_health = configList["health"]
	self.original_speed = configList["original_speed"]
	self.camp = configList["camp"]

	self.health = max_health

	# Sync properties with CharacterBody2D
	character_body = get_node("CharacterBody2D")
	if character_body:
		set_original_speed(configList["original_speed"])
		# Health is managed by character.gd, not character_body_2d.gd

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
		self.texture_path = configList["img"]
		status = "加载图像中……"
		var pic_texture = load(configList["img"])
		if pic_texture:
			Sprite.texture = pic_texture
		else:
			print("图片加载失败 At ", configList["img"])
	initiallized = true


func _input(event: InputEvent) -> void:
	if not focused:
		return

	# Only process key press and release events, not echo events
	if event is InputEventKey and not event.echo:
		var movement_vector = Vector2.ZERO
		
		# Check arrow keys
		if Input.is_action_pressed("ui_left"):
			movement_vector.x -= 1
		if Input.is_action_pressed("ui_right"):
			movement_vector.x += 1
		if Input.is_action_pressed("ui_up"):
			movement_vector.y -= 1
		if Input.is_action_pressed("ui_down"):
			movement_vector.y += 1

		# Check WASD keys
		if Input.is_action_pressed("move_left"):
			movement_vector.x -= 1
		if Input.is_action_pressed("move_right"):
			movement_vector.x += 1
		if Input.is_action_pressed("move_up"):
			movement_vector.y -= 1
		if Input.is_action_pressed("move_down"):
			movement_vector.y += 1

		# Set movement input on CharacterBody2D
		if character_body:
			character_body.set_movement_input(movement_vector)


func _on_effect_manager_ready() -> void:
	pass  # Replace with function body.

# Handle collision damage from CharacterBody2D
func handle_collision_damage(damage: float) -> void:
	suffer_damage(damage)

# Skill system methods for battle field
var is_moving_to_target_flag: bool = false
var skill_cooldown_timer: float = 0.0
var skill_cooldown_duration: float = 2.0  # 技能冷却时间（秒）
var target_position: Vector2 = Vector2.ZERO
var move_to_target_speed: float = 150.0  # 移动到目标的速度

func is_moving_to_target() -> bool:
	return is_moving_to_target_flag

func is_skill_cooldown() -> bool:
	return skill_cooldown_timer > 0.0

func trigger_skill(skill_type: String) -> void:
	if not current_focus_target:
		print("没有目标，无法释放技能")
		return
	
	# 设置移动到目标标志
	is_moving_to_target_flag = true
	
	# 设置目标位置（目标的当前位置）
	target_position = current_focus_target.global_position
	
	# 开始技能冷却
	skill_cooldown_timer = skill_cooldown_duration
	
	print("角色 ", name, " 开始释放技能: ", skill_type, " 目标: ", current_focus_target.name)

func _process_skill_system(delta: float) -> void:
	# 处理技能冷却
	if skill_cooldown_timer > 0.0:
		skill_cooldown_timer -= delta
		if skill_cooldown_timer < 0.0:
			skill_cooldown_timer = 0.0
	
	# 处理移动到目标
	if is_moving_to_target_flag and current_focus_target:
		# 更新目标位置（目标可能移动）
		target_position = current_focus_target.global_position
		
		# 计算到目标的方向
		var direction = (target_position - global_position).normalized()
		
		# 计算到目标的距离
		var distance = global_position.distance_to(target_position)
		
		# 如果距离大于攻击范围（假设50像素），继续移动
		if distance > 50.0:
			# 设置移动输入
			if character_body:
				character_body.set_movement_input(direction)
		else:
			# 到达目标位置，执行技能效果
			is_moving_to_target_flag = false
			execute_skill_effect()
			# 停止移动
			if character_body:
				character_body.set_movement_input(Vector2.ZERO)

func execute_skill_effect() -> void:
	if current_focus_target and current_focus_target.has_method("suffer_damage"):
		# 假设技能造成20点伤害
		var damage = 20.0
		current_focus_target.suffer_damage(damage)
		print("技能命中目标: ", current_focus_target.name, " 造成 ", damage, " 点伤害")
		
		# 创建技能效果显示
		var battle_field = get_parent()
		if battle_field and battle_field.has_method("add_effect_display"):
			battle_field.add_effect_display(global_position, "skill_hit")

var current_focus_target: Node2D = null

func set_focus_character(target: Node2D) -> void:
	current_focus_target = target
	print("设置角色焦点目标: ", target.name if target else "无")

# UI相关方法
func get_character_name() -> String:
	return name

func get_health() -> float:
	return health

func get_max_health() -> float:
	return max_health

func get_thumbnail_path() -> String:
	# 返回角色的缩略图路径
	return texture_path  # 默认图标，可以根据需要修改
