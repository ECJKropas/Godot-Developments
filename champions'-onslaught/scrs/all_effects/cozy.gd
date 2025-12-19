extends Node

func apply_effect(character:Node2D,delta: float=0) -> void:
	character.health+=delta

func effect_end(_character:Node2D) -> void:
	pass
