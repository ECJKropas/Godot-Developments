extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fill_tiles(num : int):
	var i = 1
	while i <= num:
		set_cell(0 , Vector2i(0,i), 1, Vector2i(0,1))
		i += 1

func fill_margin(margin : float):
	var poi: Vector2i = local_to_map(Vector2(0,margin))
	fill_tiles(poi.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
