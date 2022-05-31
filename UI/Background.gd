extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var backgrounds = {
		0: preload("res://assets/images/background0.jpeg"),
		1: preload("res://assets/images/background1.jpeg"),
		2: preload("res://assets/images/background2.jpeg"),
		3: preload("res://assets/images/background3.jpeg"),
		4: preload("res://assets/images/background4.jpeg"),
		5: preload("res://assets/images/background5.jpeg"),
		6: preload("res://assets/images/background6.jpeg"),
		7: preload("res://assets/images/background7.jpeg"),
		8: preload("res://assets/images/background8.jpeg"),
		9: preload("res://assets/images/background9.jpeg")}
		
onready var texture_rect = $TextureRect


func _ready():
	set_background(0)
	
# set background
func set_background(index:int):
	texture_rect.texture = backgrounds[index % 10]


