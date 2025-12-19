extends Node
var length: float = 256


func show_skill(character: Node2D, _our_hero: Array[Node2D], other_hero: Array[Node2D]) -> void:
	var mouse_position = character.get_viewport().get_mouse_position()
	var texture: Sprite2D = load("res://scrs/all_skills/square_area_damage_effect.tscn").instantiate()
	texture.position = mouse_position - character.position
	texture.z_index = 100
	texture.z_as_relative = false
	character.add_child(texture)

	var dart: CharacterBody2D = load("res://tscns/projectile.tscn").instantiate()
	dart.position = character.position + Vector2(0, -100)
	dart.velocity = Vector2(0, 0)
	dart.acceleration = Vector2(0, 980)
	character.current_scene.add_child(dart)

	for enemy in other_hero:
		if abs(enemy.position.x - mouse_position.x) <= length / 2:
			if abs(enemy.position.y - mouse_position.y) <= length / 2:
				enemy.suffer_damage(10)
	var dying_manager = load("res://die.tscn").instantiate()
	character.current_scene.add_child(dying_manager)
	dying_manager.die_init(texture, 1)
	await dying_manager.dead_process_finished
