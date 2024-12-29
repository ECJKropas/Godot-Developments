extends Node2D

@export var offset: int = 90
@onready var viewport:Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))

@export var player_position:Vector2

@onready var os1:TileMap = $Obstacle1
@onready var os2:TileMap = $Obstacle2

func _init(poser : Vector2):
	player_position = poser
# Called when the node enters the scene tree for the first time.
func _ready():
	os1.position.y = offset
	os2.position.y = -offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var marginDown = viewport.y - position.y - offset + player_position.y
	var marginUp = position.y - offset - player_position.y
	os1.fill_margin(marginDown)
	os2.fill_margin(marginUp)
