extends CharacterBody2D

# Movement properties - synced from character.gd
var original_speed: int = 5
var speed_amplifier: float = 1.00
@export var acceleration: float = 5.0  # Reduced from 15.0 for smoother movement
@export var friction: float = 0.95

# Collision damage properties
@export var collision_damage: float = 2.0
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
	
	# Sync speed properties from character.gd
	if character_ref and character_ref.has_method("get_speed_properties"):
		var speed_props = character_ref.get_speed_properties()
		original_speed = speed_props["original_speed"]
		speed_amplifier = speed_props["speed_amplifier"]

func _physics_process(delta: float) -> void:
	# Handle movement using built-in CharacterBody2D functions
	_handle_movement(delta)
	
	# Handle collisions
	_handle_collisions(delta)
	
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
		target_velocity = movement_vector * original_speed * speed_amplifier * 20  # 5 * 1.0 * 20 = 100 pixels/second
		# Apply smooth velocity interpolation (inertia) when moving
		velocity = velocity.lerp(target_velocity, acceleration * delta * 0.3)  # Smoother acceleration
	else:
		# Apply friction when no input - much stronger stopping
		target_velocity = Vector2.ZERO
		velocity = velocity.lerp(target_velocity, 0.9 * delta * 60)  # Strong friction to stop quickly

func _handle_collisions(delta: float) -> void:
	# Clear expired collision tracking using delta time
	if last_collision_time > 0:
		last_collision_time -= delta
		if last_collision_time <= 0:
			collided_bodies.clear()

func _handle_collision_response(collision) -> void:
	var collider = collision.get_collider()
	
	# Skip if already processed this collision
	if collider in collided_bodies:
		return
	
	# Add to processed collisions and set cooldown
	collided_bodies.append(collider)
	last_collision_time = collision_cooldown
	
	# Apply collision damage if it's another character
	if collider and collider.has_method("suffer_damage") and character_ref:
		var damage = collision_damage
		# Only apply damage to the other character, not to self
		collider.suffer_damage(damage)
		
		# Collision response - bounce back slightly
		var bounce_direction = -collision.get_normal()
		velocity = bounce_direction * 50

func set_movement_input(new_movement_vector: Vector2) -> void:
	movement_vector = new_movement_vector

func set_focus(new_focused: bool) -> void:
	focused = new_focused

func suffer_damage(damage: float) -> void:
	# Always delegate to character.gd's suffer_damage method
	if character_ref and character_ref.has_method("suffer_damage"):
		character_ref.suffer_damage(damage)

func set_speed_properties(new_original_speed: int, new_speed_amplifier: float) -> void:
	original_speed = new_original_speed
	speed_amplifier = new_speed_amplifier

func get_speed_properties() -> Dictionary:
	return {
		"original_speed": original_speed,
		"speed_amplifier": speed_amplifier
	}
