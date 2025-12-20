extends CharacterBody2D

# Movement properties - synced from character.gd
var original_speed: int = 5
var speed_amplifier: float = 1.00
@export var acceleration: float = 5.0  # Reduced from 15.0 for smoother movement
@export var friction: float = 0.8

# Collision damage properties
@export var collision_damage: float = 2.0
@export var collision_cooldown: float = 0.5

# Movement state
var target_velocity: Vector2 = Vector2.ZERO
var movement_vector: Vector2 = Vector2.ZERO
var focused: bool = false
var is_passive_movement: bool = false  # 标记是否为被动移动（如撞击）
var passive_movement_timer: float = 0.0  # 被动移动持续时间

# Collision tracking
var last_collision_time: float = 0.0
var collided_bodies: Array = []

# Reference to parent character
var character_ref: Node2D = null
var needs_position_sync: bool = false

func _ready() -> void:
	# Get reference to parent character node
	character_ref = get_parent()
	
	# 初始位置同步 - 确保CharacterBody2D在父节点的本地原点
	if character_ref:
		position = Vector2.ZERO
	
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
	
	# 保存移动前的全局位置
	var old_global_pos = global_position
	
	# 使用CharacterBody2D进行移动和碰撞检测
	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_collision_response(collision)
	
	# 计算实际移动距离
	var actual_movement = global_position - old_global_pos
	
	# 如果有实际移动，同步父节点位置
	if actual_movement.length() > 0.001 and character_ref:
		# 移动父节点
		character_ref.global_position += actual_movement
		# 将CharacterBody2D重置到本地原点（相对于父节点）
		position = Vector2.ZERO
		

func _handle_movement(delta: float) -> void:
	# Only process movement if focused
	if not focused:
		# 未focus时的处理
		if is_passive_movement:
			# 被动移动期间（如被撞击）- 使用较小的摩擦力，让角色能自然滑动和反弹
			velocity = velocity.lerp(Vector2.ZERO, friction * delta * 2)
		else:
			# 完全静止时 - 使用正常的摩擦力
			velocity = velocity.lerp(Vector2.ZERO, friction * delta * 10)
		return
	
	# Calculate target velocity based on input
	if movement_vector.length() > 0:
		movement_vector = movement_vector.normalized()
		target_velocity = movement_vector * original_speed * speed_amplifier * 20  # 5 * 1.0 * 20 = 100 pixels/second
		# Apply smooth velocity interpolation (inertia) when moving
		velocity = velocity.lerp(target_velocity, acceleration * delta * 0.3)  # Smoother acceleration
	else:
		# Apply friction when no input - smoothly stop at current position
		velocity = velocity.lerp(Vector2.ZERO, friction * delta * 15)  # Moderate friction to stop smoothly

func _handle_collisions(delta: float) -> void:
	# Clear expired collision tracking using delta time
	if last_collision_time > 0:
		last_collision_time -= delta
		if last_collision_time <= 0:
			collided_bodies.clear()
	
	# 更新被动移动计时器
	if passive_movement_timer > 0:
		passive_movement_timer -= delta
		if passive_movement_timer <= 0:
			is_passive_movement = false

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
		
		# 标记被动移动状态
		is_passive_movement = true
		passive_movement_timer = 1.0  # 被动移动持续1.0秒

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
