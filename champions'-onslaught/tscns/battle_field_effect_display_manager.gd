extends Control

var effect_templates = {}
var active_effects = {}
var effect_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("EffectDisplayManager节点创建完成")
	initialize()

func initialize() -> void:
	print("开始初始化EffectDisplayManager...")
	
	# 清除示例节点
	var children_to_remove = []
	for child in get_children():
		if child.name.begins_with("Example"):
			children_to_remove.append(child)
	
	for child in children_to_remove:
		child.queue_free()
		print("移除示例节点: ", child.name)
	
	print("特效显示管理器初始化完成，移除了 ", children_to_remove.size(), " 个示例节点")

func show_effect(effect_type: String, position: Vector2, target = null) -> int:
	# 生成唯一的特效ID
	var effect_id = effect_counter
	effect_counter += 1
	
	# 创建特效节点
	var effect_node = create_effect_node(effect_type, position, target)
	if effect_node:
		active_effects[effect_id] = effect_node
		print("创建特效: ", effect_type, " ID: ", effect_id)
		return effect_id
	
	return -1

func create_effect_node(effect_type: String, position: Vector2, target) -> Control:
	# 创建基础的特效背景
	var effect_background = TextureRect.new()
	effect_background.name = "Effect_" + effect_type + "_" + str(effect_counter)
	effect_background.position = position
	effect_background.size = Vector2(64, 64)  # 默认大小
	
	# 尝试加载特效背景纹理
	var background_texture = load("res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0002.png")
	if background_texture:
		effect_background.texture = background_texture
		effect_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	# 创建缩略图
	var effect_thumbnail = TextureRect.new()
	effect_thumbnail.name = "Thumbnail"
	effect_thumbnail.position = Vector2(8, 8)
	effect_thumbnail.size = Vector2(48, 48)
	effect_thumbnail.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	# 尝试加载特效缩略图（根据特效类型）
	var thumbnail_path = get_effect_thumbnail_path(effect_type)
	if thumbnail_path and FileAccess.file_exists(thumbnail_path):
		effect_thumbnail.texture = load(thumbnail_path)
	
	effect_background.add_child(effect_thumbnail)
	add_child(effect_background)
	
	# 设置特效动画或持续时间
	animate_effect(effect_background)
	
	return effect_background

func get_effect_thumbnail_path(effect_type: String) -> String:
	# 根据特效类型返回对应的缩略图路径
	match effect_type:
		"heal":
			return "res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0000.png"
		"damage", "skill_hit":
			return "res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0002.png"
		"buff":
			return "res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0004.png"
		"debuff":
			return "res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0006.png"
		_:
			return "res://assets/UIPack/Tiles/Large tiles/Thin outline/tile_0001.png"

func animate_effect(effect_node: Control) -> void:
	# 创建简单的缩放动画
	var tween = get_tree().create_tween()
	tween.tween_property(effect_node, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(effect_node, "scale", Vector2(1.0, 1.0), 0.2)
	
	# 2秒后自动移除特效
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(effect_node):
		remove_effect(effect_node)

func hide_effect(effect_id: int) -> void:
	if effect_id in active_effects:
		var effect_node = active_effects[effect_id]
		if is_instance_valid(effect_node):
			remove_effect(effect_node)
		active_effects.erase(effect_id)

func remove_effect(effect_node: Control) -> void:
	# 创建淡出动画
	var tween = get_tree().create_tween()
	tween.tween_property(effect_node, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	if is_instance_valid(effect_node):
		effect_node.queue_free()

func clear_all_effects() -> void:
	for effect_id in active_effects.keys():
		hide_effect(effect_id)
	active_effects.clear()

func get_active_effects() -> Dictionary:
	return active_effects.duplicate()

# 添加兼容方法，用于战场系统调用
func add_effect(position: Vector2, effect_type: String) -> int:
	return show_effect(effect_type, position)