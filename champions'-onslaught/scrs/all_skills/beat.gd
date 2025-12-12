extends Node

func show_skill(character:Node2D,our_hero:Array[Node2D],other_hero:Array[Node2D]) -> void:
    for enemy in other_hero:
        enemy.health -= 10
    character.effects_list.append("cozy")