extends TextureRect

@export var image_path: String = "res://assets/images/splash_screen.jpeg"

var image_height = 832

func adjust_modulate(num: int):
	modulate.a = num

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var image := Image.load_from_file(image_path)
	if image == null:
		push_error("Failed to load image: %s" % image_path)
		return
	
	var image_texture := ImageTexture.create_from_image(image)
	print(image_texture.get_height())
	
	image_height = image.get_height()
	texture = image_texture
	
	# 确保填充整个父容器
	set_anchors_preset(Control.PRESET_FULL_RECT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var window_size = get_viewport().size
	size = window_size
