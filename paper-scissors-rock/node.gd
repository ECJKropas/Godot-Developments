extends Node
import numpy as np
import random

# 初始化模式统计数组（3x3x3）
pattern = np.zeros((3, 3, 3), dtype=int)
history = []

comp_win = 0
human_win = 0
ch_tie = 0

# 胜负判断字典
beats = {0: 2, 1: 0, 2: 1}  # 电脑出的动作对应的胜利动作

def comp_choose():
	# 电脑选择策略
	if len(history) >= 2:
		a_prev, b_prev = history[-2], history[-1]
		counts = pattern[a_prev, b_prev]
		
		# 处理全零情况
		if np.all(counts == 0):
			predicted = random.randint(0, 2)
		else:
			# 找到所有最大值并随机选择
			# max_count = np.max(counts)
			# candidates = [i for i in range(3) if counts[i] == max_count]
			# predicted = random.choice(candidates)
			possibilities = np.array([(i + 1) * 1.0 / (sum(counts) + len(counts)) for i in counts])
			predicted = np.random.choice(range(3), size = 1, p = possibilities)[0]
		
		computer_choice = beats[predicted]
	else:
		computer_choice = random.randint(0, 2)
	return computer_choice

def user_choose():
	# 获取用户输入
	while True:
		user_input = input("\n请输入你的选择（0-石头，1-剪刀，2-布，q-退出）：")
		if user_input == 'q':
			print(f"你赢了 {human_win} 次")
			print(f"电脑赢了 {comp_win} 次")
			raise
			break
		if user_input.isdigit():
			user_choice = int(user_input) % 3
			break
		print("输入无效，请重新输入！")
	return user_choice 

def update_pattern(user_choice):
	# 更新历史记录
	history.append(user_choice)
	
	# 更新模式统计（当有足够历史时）
	if len(history) >= 3:
		a, b, c = history[-3], history[-2], history[-1]
		pattern[a, b, c] += 1


while True:
	# 电脑选择策略
	computer_choice = comp_choice()
	
	# 获取用户输入
	user_choice = user_choose()

	# 更新
	update_pattern(user_choice)

	# 显示结果
	print(f"电脑出了：{computer_choice} ({['石头', '剪刀', '布'][computer_choice]})")
	print(f"你出了：{user_choice} ({['石头', '剪刀', '布'][user_choice]})")

	# 判断胜负
	if user_choice == computer_choice:
		print("平局！")
		ch_tie += 1
	elif (user_choice - computer_choice) % 3 == 2:
		print("你赢了！")
		human_win += 1
	else:
		print("电脑赢了！")
		comp_win += 1

	# 显示当前学习状态（调试用）
	# print("\n当前模式统计：")
	# print(pattern)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
