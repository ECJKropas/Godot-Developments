extends Node


func apply_effect(character: Node2D, delta: float = 0) -> void:
	character.original_speed *= 0.2


func effect_end(character: Node2D) -> void:
	character.original_speed /= 0.2
