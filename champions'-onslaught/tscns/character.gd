extends Node2D

@export var type:String = "default"
@export var summon_id:int

@export var health:int = 100
@export var speed_amplifier:float = 1.00

@onready var HealthBar:ProgressBar = get_node("HealthBar")
@onready var Sprite:Sprite2D = get_node("Sprite2D")


var effects:Array = []

var skills:Array

var attrs = {
	"Lust":0,
	"Gluttony":0,
	"Greed":0,
	"Sloth":0,
	"Wrath":0,
	"Envy":0,
	"Pride":0
}

func _process(_delta: float) -> void:
	HealthBar.value=health
	

var status = ""
var initiallized = false

func init_role(configList: Dictionary) -> void:
	initiallized = false
	self.type = configList["type"]
	self.summon_id = configList["summon_id"]
	self.health = configList["health"]

	var current_scene = get_tree().current_scene
	if current_scene.has("skill_dictionary"):
		status = "加载技能中……"
		self.skills = current_scene.skill_dictionary[self.summon_id]

	for key in configList.keys():
		if key in attrs.keys():
			attrs[key] = configList[key]
	
	if "img" in configList.keys():
		status = "加载图像中……"
		Sprite.texture = load(configList["img"])
