extends CharacterBody2D

@export var acceleration:Vector2
@export var die_on_collision:bool = false

func _physics_process(delta: float) -> void:
	self.velocity += acceleration*delta
	var collision = move_and_collide(velocity*delta)
	if collision:
		print("col",collision.get_collider().get_parent().suffer_damage(10))
		
