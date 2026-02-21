extends TextEdit

var max_log_lines = 100
var log_history = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 设置文本框为只读（兼容方式）
	set_editable(false)
	# 确保文本框行为正确
	set_selecting_enabled(false)
	
	# 添加初始日志
	add_log("战场系统初始化完成")
	add_log("等待角色加载...")

func add_log(message: String) -> void:
	# 获取当前时间戳（简化版本）
	var time_dict = Time.get_time_dict_from_system()
	var timestamp = "%02d:%02d:%02d" % [time_dict.hour, time_dict.minute, time_dict.second]
	
	var log_entry = "[" + timestamp + "] " + message
	
	# 添加到历史记录
	log_history.append(log_entry)
	
	# 限制历史记录大小
	if log_history.size() > max_log_lines:
		log_history.remove_at(0)
	
	# 更新显示
	update_display()
	
	print("战场日志: ", message)

func update_display() -> void:
	# 重新构建文本
	var full_text = ""
	for entry in log_history:
		full_text += entry + "\n"
	
	# 更新文本框
	text = full_text
	
	# 滚动到底部（兼容Godot 4.x）
	if log_history.size() > 0:
		# 使用scroll_vertical来滚动到底部
		var total_lines = get_line_count()
		var visible_lines = get_visible_line_count()
		if total_lines > visible_lines:
			scroll_vertical = total_lines - visible_lines

func clear_logs() -> void:
	log_history.clear()
	update_display()
	add_log("日志已清空")

func get_log_history() -> Array:
	return log_history.duplicate()
