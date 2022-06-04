extends Node

const DEBUG = false

var circles_per_level = 5

var color_schemes = {
	"NEON1": {
		'background': Color8(50, 50, 70),
		'player_body': Color8(203, 255, 0),
		'player_trail': Color8(204, 0, 255),
		'circle_fill': Color8(255, 0, 110), 
		'circle_static': Color8(0, 255, 102),
		'circle_limited': Color8(204, 0, 255)
	},
	"NEON2": {
		'background': Color8(0, 0, 0),
		'player_body': Color8(246, 255, 0),
		'player_trail': Color8(255, 255, 255),
		'circle_fill': Color8(255, 0, 110),
		'circle_static': Color8(151, 255, 48),
		'circle_limited': Color8(127, 0, 255)
	},
	"NEON3": {
		'background': Color8(76, 84, 95),
		'player_body': Color8(255, 0, 187),
		'player_trail': Color8(255, 148, 0),
		'circle_fill': Color8(255, 148, 0),
		'circle_static': Color8(170, 255, 0),
		'circle_limited': Color8(204, 0, 255)
	}
}

var theme = color_schemes["NEON1"]

var admob = null
var enable_ads = true setget set_enable_ads
var interstitial_rate = 0.5

# Game data
var save_dict = {
		"enable_sound" : true,
		"enable_music" : true,
		"enable_ads" : true,
		"highscore" : 0,
		"life" : 2
	}
# Note: This can be called from anywhere inside the tree. This function is
# path independent.
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	# Store the save dictionary as a new line in the save file.
	save_game.store_line(Marshalls.utf8_to_base64(to_json(save_dict)))
	save_game.close()

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	# Get the saved dictionary from the next line in the save file
	var node_data:Dictionary = parse_json(Marshalls.base64_to_utf8(save_game.get_as_text()))
	if not node_data.empty():
		for key in node_data.keys():
			save_dict[key] = node_data[key]
	save_game.close()
	enable_ads = save_dict["enable_ads"]

static func rand_weighted(weights):
	var sum = 0
	for weight in weights:
		sum += weight
	var num = rand_range(0, sum)
	for i in weights.size():
		if num < weights[i]:
			return i
		num -= weights[i]
		
		
func set_enable_ads(value):
	enable_ads = value
	save_dict["enable_ads"] = value
	if admob:
		if enable_ads:
			admob.show_banner()
		if !enable_ads:
			admob.hide_banner()
	save_game()
		
func _ready():
	load_game()
