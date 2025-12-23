extends TextureRect

@onready var health_bar = $HealthBar
@onready var thumbnail = $Thumbnail
var battle_field = null  # 将在_ready中动态获取

var current_character = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 等待场景完全加载
	await get_tree().create_timer(0.2).timeout
	
	# 动态查找BattleField节点
	battle_field = find_battle_field_node()
	if battle_field:
		print("成功找到BattleField节点: ", battle_field.name)
		update_display()
	else:
		print("警告: 无法找到BattleField节点")

# 动态查找BattleField节点
func find_battle_field_node() -> Node:
	if get_tree().current_scene.name == "BattleField":
		return get_tree().current_scene
	else: 
		print("警告: 当前场景根节点不是BattleField")
		return null

	var current_node = get_parent()
	while current_node:
		if current_node.has_method("get_current_focus_character"):
			return current_node
		current_node = current_node.get_parent()
	return null

func _process(delta: float) -> void:
	# 实时更新显示
	update_display()

func update_display() -> void:
	battle_field = find_battle_field_node()
	if not battle_field:
		print("错误: BattleField节点未找到")
		return
	
	# 获取当前焦点角色
	var focus_character = null
	if battle_field.has_method("get_current_focus_character"):
		focus_character = battle_field.get_current_focus_character()
	else:
		print("错误: BattleField没有get_current_focus_character方法")
		return
	
	if focus_character == current_character:
		return  # 没有变化，不需要更新
	
	current_character = focus_character
	
	if current_character:
		# 更新角色名称（如果有标签显示）
		if current_character.has_method("get_character_name"):
			print("更新角色基本信息显示: ", current_character.get_character_name())
		
		# 更新血条
		if health_bar and current_character.has_method("get_health") and current_character.has_method("get_max_health"):
			var current_health = current_character.get_health()
			var max_health = current_character.get_max_health()
			health_bar.value = (current_health / max_health) * 100
			print("更新血条: ", current_health, "/", max_health)
		
		# 更新缩略图
		if thumbnail and current_character.has_method("get_thumbnail_path"):
			var thumbnail_path = current_character.get_thumbnail_path()
			if thumbnail_path and FileAccess.file_exists(thumbnail_path):
				thumbnail.texture = load(thumbnail_path)
				print("更新缩略图: ", thumbnail_path)
	else:
		print("没有焦点角色")
		# 重置显示
		if health_bar:
			health_bar.value = 0
		if thumbnail:
			thumbnail.texture = null

func set_character(character):
	current_character = character
	update_display()
