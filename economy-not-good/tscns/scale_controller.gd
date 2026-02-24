extends Control

@onready var Board:Control = $Board
@onready var father:BoxContainer = get_parent()

const BSize = Vector2(176,176)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.custom_minimum_size = BSize * Board.scale
	Board.position.y = 0
	var left_margin:float = self.position.x
	var right_margin:float = father.size.x-self.position.x-BSize.x*Board.scale.x
	var half_delta:float = abs(left_margin-right_margin)/2
	Board.position.x = half_delta * Board.scale.x




func _on_h_slider_value_changed(value: float) -> void:
	Board.scale = Vector2.ONE * value
	
