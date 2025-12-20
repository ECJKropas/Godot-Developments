extends Node2D

@onready var character_manager = $CharacterManager
@onready var tile_map_manager = $TileMapManager
@onready var marker_2d = $Marker2D

var current_focus_target = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("2D首席管理器初始化完成")

func _input(event: InputEvent) -> void:
	# 处理鼠标点击锁定目标
	if Input.is_action_just_pressed("focus_target"):
		lock_target()
	
	# 处理技能释放
	if Input.is_action_just_pressed("skill_q"):
		trigger_skill("skill_q")
	elif Input.is_action_just_pressed("skill_e"):
		trigger_skill("skill_e")
	
	# 测试特效显示系统
	if Input.is_action_just_pressed("test_effect_heal"):
		test_effect("heal")
	elif Input.is_action_just_pressed("test_effect_damage"):
		test_effect("damage")
	elif Input.is_action_just_pressed("test_effect_buff"):
		test_effect("buff")
	elif Input.is_action_just_pressed("test_effect_debuff"):
		test_effect("debuff")

func lock_target() -> void:
	# 获取鼠标在2D世界中的位置
	var mouse_pos = get_viewport().get_mouse_position()
	
	# 将屏幕坐标转换为世界坐标
	var world_mouse_pos = get_canvas_transform().affine_inverse() * mouse_pos
	
	# 检测鼠标位置的碰撞体（只检测敌方组）
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_mouse_pos
	query.collision_mask = 1  # 确保敌方角色的碰撞层和此mask匹配
	var results = get_world_2d().direct_space_state.intersect_point(query)
	
	# 遍历检测结果，找到敌方角色
	for result in results:
		var body = result.get("collider")
		if body and body.is_in_group("enemies"):
			current_focus_target = body
			print("锁定目标：", current_focus_target.name)
			
			# 通知战场主节点更新焦点
			var battle_field = get_parent()
			if battle_field and battle_field.has_method("set_focus_character"):
				battle_field.set_focus_character(body)
			return
	
	# 未找到目标则清空
	current_focus_target = null
	print("未锁定任何目标")

func trigger_skill(skill_type: String) -> void:
	if not current_focus_target:
		print("没有锁定目标，无法释放技能")
		return
	
	# 获取当前焦点角色
	var focus_character = character_manager.get_focused_character()
	if not focus_character:
		print("没有焦点角色")
		return
	
	# 检查角色是否正在移动或技能冷却中
	if focus_character.has_method("is_moving_to_target") and focus_character.is_moving_to_target():
		print("角色正在移动中，等待到达目标")
		return
	
	if focus_character.has_method("is_skill_cooldown") and focus_character.is_skill_cooldown():
		print("技能冷却中")
		return
	
	# 触发技能移动到目标
	if focus_character.has_method("trigger_skill"):
		focus_character.trigger_skill(skill_type)
		print("触发技能：", skill_type, " 目标：", current_focus_target.name)

func get_current_focus_target():
	return current_focus_target

func clear_focus_target() -> void:
	current_focus_target = null
	print("清除目标锁定")

# 测试特效显示
func test_effect(effect_type: String) -> void:
	# 获取当前焦点角色位置作为特效位置
	var focus_character = character_manager.get_focused_character()
	if focus_character:
		var effect_pos = focus_character.global_position + Vector2(0, -50)
		var battle_field = get_parent()
		if battle_field and battle_field.has_method("add_effect_display"):
			battle_field.add_effect_display(effect_pos, effect_type)
			print("测试特效: ", effect_type, " 位置: ", effect_pos)
	else:
		print("没有焦点角色，无法测试特效")
