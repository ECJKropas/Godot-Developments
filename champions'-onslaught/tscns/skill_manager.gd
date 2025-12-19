extends Node2D

var priority_key_list: String = "QERTYUIOPFGHJKLZXCVBNM"

var skills_list: Array
var skills_funcs: Array
var skills_cd: Array

var skill_start_time: Dictionary

var timer: float = 0.0

var current_scene = null


func _process(delta: float) -> void:
	timer += delta
	for i in range(len(skills_list)):
		if skill_start_time.has(skills_list[i]):
			if skill_start_time[skills_list[i]] + skills_cd[i] <= timer:
				print(skills_list[i], "cd end")
				skill_start_time.erase(skills_list[i])


# 安全获取当前场景的函数
func get_current_scene():
	await tree_entered
	if current_scene == null and is_inside_tree():
		current_scene = get_tree().current_scene
	return current_scene


func _input(event: InputEvent) -> void:
	var parent = get_parent()
	if not parent.focused:
		return

	# Handle Skill Stimulator
	if current_scene == null:
		get_current_scene()
	if event is InputEventKey and event.pressed and not event.echo:
		# 判断 keycode 是否在 KEY_A ~ KEY_Z 范围内
		if event.keycode >= KEY_A and event.keycode <= KEY_Z:
			# 转换为字母字符串（如 KEY_A → "A"，KEY_B → "B"）
			var letter = String.chr("A".unicode_at(0) + (event.keycode - KEY_A))
			print("按下了字母键：", letter)
			for i in range(priority_key_list.length()):
				var key = priority_key_list[i]
				if letter == key:
					if i < skills_list.size():
						if not skill_start_time.has(skills_list[i]):
							print("使用了技能：", skills_list[i])
							skill_start_time[skills_list[i]] = timer
							var scene = current_scene
							if scene != null and scene != parent:
								print(parent.camp)
								skills_funcs[i].show_skill(parent, scene.get_our_hero(parent.camp), scene.get_other_hero(parent.camp))
					break


func load_funcs(skills: Array) -> void:
	skills_list = skills
	var scene = current_scene
	if scene == null:
		scene = await get_current_scene()
	if scene != null and scene != self:
		print("加载技能中……")
		for skill in skills_list:
			print(scene.skills_mapping)
			var skill_data = scene.skills_mapping[skill]
			print("加载技能中…… " + skill_data["name"])
			var skill_script = load(skill_data["scr"])
			skills_cd.append(skill_data["cd"])
			var skill_instance = skill_script.new()
			skills_funcs.append(skill_instance)


func _ready() -> void:
	get_current_scene()
	print("SkillManagerReady")
