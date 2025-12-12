extends Node

func apply_effect(character:Node2D) -> void:
    character.health+=1

func effect_end(_character:Node2D) -> void:
    pass