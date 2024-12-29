extends Sprite2D

@onready var player = $"../Bird"
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# 计算x毫秒后的位置
func calculate_position_in_x_milliseconds(x_ms):
	# 将毫秒转换为秒
	var velocity_x = player.velox
	var delta = x_ms / 1000.0
	# 重力加速度乘以时间（秒）
	var gravity_effect = gravity * delta
	# 计算y方向的速度变化
	var velocity_y = player.velocity.y
	# 计算y方向的位置变化，使用公式s = 0.5 * a * t^2
	var position_y = player.position.y + velocity_y * delta + 0.5 * gravity * (delta ** 2)
	# x方向的位置变化
	var position_x = player.position.x + velocity_x * delta
	# 返回新的位置，类型为Vector2
	return Vector2(position_x, position_y)

# 假设我们要计算1000毫秒后的位置


func _on_timer_timeout():
	var position_after_200_ms = calculate_position_in_x_milliseconds(200)
	position = position_after_200_ms
