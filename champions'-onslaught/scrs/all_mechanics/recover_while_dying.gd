extends Node


func check_and_apply(character: Node2D):
	if character.health <= 10:
		character.add_effect("cozy")
