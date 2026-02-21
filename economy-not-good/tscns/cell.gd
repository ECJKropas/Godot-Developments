extends Control

@export var textures: Array[Texture2D]
@export var disabled: bool = false
var select_pic: Array[Texture2D]

var current_role: int = 0


@onready var Selected: TextureRect = $Selected
@onready var TextureB: TextureButton = $TextureButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select_pic.append(load("res://assets/current_selected.png"))
	select_pic.append(load("res://assets/current_selected_exclaim.png"))
	Selected.visible = false
	TextureB.texture_normal.clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_role = get_tree().current_scene.current_role

	if is_mouse_in():
		if disabled:
			Selected.texture = select_pic[1]
		else:
			Selected.texture = select_pic[0]
		Selected.visible = true
	else:
		Selected.visible = false


func is_mouse_in():
	var mouse_position: Vector2 = get_local_mouse_position()
	return -8 <= mouse_position.x and mouse_position.x <= 8 and -8 <= mouse_position.y and mouse_position.y <= 8
