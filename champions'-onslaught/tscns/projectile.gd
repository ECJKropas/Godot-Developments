extends CharacterBody2D

@export var acceleration: Vector2 = Vector2(0, 980)  # 默认重力加速度 980 px/s²
@export var die_on_collision: bool = false
@export var bounce_threshold: float = 200.0  # 反弹速度阈值（px/s）
@export var bounce_damping: float = 0.7  # 反弹衰减系数（0-1）


func _physics_process(delta: float) -> void:
	# 更新速度 - 使用正确的速度计算方法
	velocity += acceleration * delta

	# 移动并检测碰撞
	var collision = move_and_collide(velocity * delta)
	if collision:
		print("col", collision.get_collider().get_parent().suffer_damage(10))

		# 获取碰撞前的速度大小
		var speed_before_collision = velocity.length()

		# 如果速度大于反弹阈值，则产生反弹效果
		if speed_before_collision > bounce_threshold:
			# 基于碰撞法线计算反弹速度
			var normal = collision.get_normal()
			velocity = velocity.bounce(normal) * bounce_damping
		else:
			# 速度太小，直接停止
			velocity = Vector2.ZERO

		# 如果设置了碰撞销毁，则销毁投射物
		if die_on_collision:
			queue_free()
