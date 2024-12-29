extends ColorRect

@onready var bird:CharacterBody2D = $"../Bird"
@onready var viewport:Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),ProjectSettings.get_setting("display/window/size/viewport_height"))

# Called when the node enters the scene tree for the first time.
func _ready():
	self.size = viewport


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x = bird.position.x - viewport.x/2
	position.y = min(bird.position.y - viewport.y/2, -1024-viewport.y)
