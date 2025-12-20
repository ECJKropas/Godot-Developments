extends Node


func apply_effect(character: Node2D, delta: float = 0) -> void:
	character.multiply_speed_amplifier(0.2)


func effect_end(character: Node2D) -> void:
	character.multiply_speed_amplifier(5)
