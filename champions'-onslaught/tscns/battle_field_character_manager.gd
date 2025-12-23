extends Node2D

var characters = []
var focused_character = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func add_character(character_node):
	if character_node:
		characters.append(character_node)
		add_child(character_node)
		print("添加角色到管理器: ", character_node.name)

func remove_character(character_node):
	if character_node in characters:
		characters.erase(character_node)
		print("从管理器移除角色: ", character_node.name)
		
		# 如果被移除的是焦点角色，清除焦点
		if character_node == focused_character:
			focused_character = null

func get_characters() -> Array:
	return characters

func get_characters_by_camp(camp: String) -> Array:
	var camp_characters = []
	for character in characters:
		if character.has_method("get_camp") and character.get_camp() == camp:
			camp_characters.append(character)
	return camp_characters

func set_focused_character(character):
	# 清除之前的焦点
	if focused_character and focused_character.has_method("set_focused"):
		focused_character.set_focused(false)
	
	# 设置新的焦点
	focused_character = character
	if focused_character and focused_character.has_method("set_focused"):
		focused_character.set_focused(true)
		print("设置焦点角色: ", focused_character.name)

func get_focused_character():
	return focused_character

func get_all_friendly_characters() -> Array:
	return get_characters_by_camp("friend")

func get_all_enemy_characters() -> Array:
	return get_characters_by_camp("enemy")

func _process(delta: float) -> void:
	# 更新角色状态，处理死亡角色等
	for character in characters:
		if character and character.has_method("is_alive") and not character.is_alive():
			remove_character(character)
			character.queue_free()
