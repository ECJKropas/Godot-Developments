extends Control

@export var disabled: bool = false
@export var occupied: int = -1  # Defaut(No occupy) set as -1
@export var textures: Array[Texture2D]

var vision_role: int = -1  # This variable represents the role corresponding to the current perspective and is obtained in real time from the root node.

signal set_cell(describe: Dictionary)

var select_pic: Array[Texture2D]

var current_role: int = 0

@onready var TextureB: TextureButton = $TextureButton


func blend_pictures(texture1: Texture2D, texture2: Texture2D) -> ImageTexture:
	var blended = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	blended.blend_rect(texture1.get_image(), Rect2i(0, 0, 16, 16), Vector2.ZERO)
	blended.blend_rect(texture2.get_image(), Rect2i(0, 0, 16, 16), Vector2.ZERO)
	return ImageTexture.create_from_image(blended)


func get_grayscale_texture(texture: Texture2D) -> ImageTexture:
	var image = texture.get_image()

	# 2. 转换为灰度
	image.convert(Image.FORMAT_RGBA8)  # 确保格式支持透明度（可选）
	var width = image.get_width()
	var height = image.get_height()

	# 遍历每个像素，计算灰度值（使用标准亮度公式：0.299R + 0.587G + 0.114B）
	for x in width:
		for y in height:
			var color = image.get_pixel(x, y)
			var gray = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
			image.set_pixel(x, y, Color(gray, gray, gray, color.a))  # 保留透明度

	return ImageTexture.create_from_image(image)


func reset_select_pic():
	self.select_pic = []
	self.select_pic.append(load("res://assets/current_selected.png"))
	self.select_pic.append(load("res://assets/current_selected_exclaim.png"))


func reset_texture_button_textures(new_texture: Texture2D):
	TextureB.texture_normal = new_texture

	reset_select_pic()
	for spi in range(len(self.select_pic)):
		self.select_pic[spi] = blend_pictures(self.select_pic[spi], new_texture)
	TextureB.texture_hover = self.select_pic[int(disabled)]

	TextureB.texture_disabled = get_grayscale_texture(new_texture)


# This function is used to get the current role and vision role from the root node.
func get_data_from_root():
	current_role = get_tree().current_scene.current_role
	vision_role = get_tree().current_scene.vision_role


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TextureB.pressed.connect(set_as)

	# 创建一个 16x16 大小的空图像，格式为 RGBA8
	var image = Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	# 将图像的所有像素设置为透明黑色 (你也可以设置为其他颜色，例如白色 Color.WHITE)
	image.fill(Color.TRANSPARENT)
	# 基于这个图像创建一个 ImageTexture
	var empty_texture = ImageTexture.create_from_image(image)

	reset_texture_button_textures(empty_texture)


func set_textures(t_from_fa: Array[Texture2D]):
	self.textures = t_from_fa


func set_as(role: int = -1, ignore_warning: bool = false):
	get_data_from_root()

	if occupied >= 0 and not ignore_warning:
		print("Cell is occupied")
		return -2

	if role < 0:
		role = vision_role

	if role != current_role and not ignore_warning:
		print("Role is not as expected")
		return -1

	if role >= 0 and role < textures.size():
		reset_texture_button_textures(textures[role])
		occupied = role
		set_cell.emit(get_describe())
		print("Set!")
		return 0
	else:
		if not ignore_warning:
			print("Role index out of range")
			return 3221225477


func get_current_occupied():
	return occupied


func set_disabled(disable_or_not: bool = true):
	if disable_or_not != disabled:
		self.disabled = disable_or_not
		TextureB.texture_hover = self.select_pic[int(disable_or_not)]
		TextureB.disabled = disable_or_not


func get_describe():
	return {
		"name": name,
		"disabled": disabled,
		"occupied": occupied,
	}


func set_as_describe(describe: Dictionary):
	if "disabled" in describe:
		self.disabled = describe["disabled"]
		set_disabled(self.disabled)
	if "occupied" in describe:
		self.occupied = describe["occupied"]
		set_as(self.occupied, true)
	get_data_from_root()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
