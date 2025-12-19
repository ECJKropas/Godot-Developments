extends CharacterBody2D

# Movement properties
@export var original_speed: int = 5
@export var speed_amplifier: float = 1.00
@export var acceleration: float = 15.0
@export var friction: float = 0.85
@export var max_health: int = 100
@export var health: float = 100

# Collision damage properties
@export var collision_damage: float = 10.0
@export var collision_cooldown: float = 0.5

# Movement state
var target_velocity: Vector2 = Vector2.ZERO
var movement_vector: Vector2 = Vector2.ZERO
var focused: bool = false

# Collision tracking
var last_collision_time: float = 0.0
var collided_bodies: Array = []

# Reference to parent character
var character_ref: Node2D = null

func _ready() -> void:
	# Get reference to parent character node
	character_ref = get_parent()

func _physics_process(delta: float) -> void:
	# Handle movement using built-in CharacterBody2D functions
	_handle_movement(delta)
	
	# Handle collisions
	_handle_collisions()
	
	# Move the character
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision_response(collision)

func _handle_movement(delta: float) -> void:
	# Only process movement if focused
	if not focused:
		velocity = Vector2.ZERO
		return
	
	# Calculate target velocity based on input
	if movement_vector.length() > 0:
		movement_vector = movement_vector.normalized()
		target_velocity = movement_vector * original_speed * speed_amplifier * 100
	else:
		target_velocity = Vector2.ZERO
	
	# Apply smooth velocity interpolation (inertia)
	velocity = velocity.lerp(target_velocity, acceleration * delta)
	
	# Apply friction when no input
	if target_velocity.length() == 0:
		velocity = velocity * friction

func _handle_collisions() -> void:
	# Clear expired collision tracking
	var current_time = Time.get_time_dict_from_system()["unix"] if Engine.get_process_frames() > 0 else 0
	if current_time - last_collision_time > collision_cooldown:
		collided_bodies.clear()

func _handle_collision_response(collision) -> void:
	var collider = collision.get_collider()
	
	# Skip if already processed this collision
	if collider in collided_bodies:
		return
	
	# Add to processed collisions
	collided_bodies.append(collider)
	last_collision_time = Time.get_time_dict_from_system()["unix"] if Engine.get_process_frames() > 0 else 0
	
	# Apply collision damage if it's another character
	if collider and collider.has_method("suffer_damage") and character_ref:
		var damage = collision_damage
		# Apply damage to self
		suffer_damage(damage)
		# Apply damage to other character
		collider.suffer_damage(damage)
		
		# Collision response - bounce back slightly
		var bounce_direction = -collision.get_normal()
		velocity = bounce_direction * 50

func set_movement_input(new_movement_vector: Vector2) -> void:
	movement_vector = new_movement_vector

func set_focus(new_focused: bool) -> void:
	focused = new_focused

func suffer_damage(damage: float) -> void:
	if character_ref and character_ref.has_method("suffer_damage"):
		character_ref.suffer_damage(damage)
	elif character_ref and character_ref.has_method("handle_collision_damage"):
		character_ref.handle_collision_damage(damage)
	else:
		# Fallback damage calculation if no character reference
		health = max(health - damage, 0)

func get_health() -> float:
	return health

func get_max_health() -> int:
	return max_health

func set_health_properties(max_hp: int, current_hp: float) -> void:
	max_health = max_hp
	health = current_hp