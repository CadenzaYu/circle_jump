extends Node

const LEVEL_UP_SOUND = preload("res://assets/audio/level_up.ogg")
const GAME_OVER_SOUND = preload("res://assets/audio/game_over.ogg")
var Circle = preload("res://objects/Circle.tscn")
var Jumper = preload("res://objects/Jumper.tscn")

var player
var score = 0 setget set_score
var num_circles = 0
var highscore = 0
var new_highscore = false
var level = 0
var bonus = 0 setget set_bonus

onready var admob = $Admob
onready var audio_player := $AudioPlayer
onready var unityads = $UnityAds
onready var background = $Background

func _ready():
	if settings.DEBUG:
		admob.is_real = false
		admob.banner_id = "ca-app-pub-3940256099942544/6300978111"
		admob.interstitial_id = "ca-app-pub-3940256099942544/1033173712"
		admob.rewarded_id = "ca-app-pub-3940256099942544/5224354917"
		unityads._is_test_mode = true
		
	settings.admob = admob
	admob.load_banner()
	admob.load_interstitial()
	randomize()
	highscore = settings.save_dict["highscore"]
	$HUD.hide()
	$Background/ColorRect.color = settings.theme["background"]
	
func new_game():
	new_highscore = false
	admob.hide_banner()
	self.score = 0
	self.bonus = 0
	num_circles = 0
	level = 1
	background.set_background(level)
	$HUD.update_score(score, 0)
	$Camera2D.position = $StartPosition.position
	player = Jumper.instance()
	player.position = $StartPosition.position
	add_child(player)
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
	spawn_circle($StartPosition.position)
	$HUD.show()
	$HUD.show_message("Go!")
	if settings.save_dict["enable_music"]:
		$Music.volume_db = 0
		$Music.play()
	
func spawn_circle(_position=null):
	var c = Circle.instance()
	if !_position:
		var x = rand_range(-150, 150)
		var y = rand_range(-450, -350)
		y -= level * 10
		y = max(y, -650)
		_position = player.target.position + Vector2(x, y)
	add_child(c)
	c.connect("full_orbit", self, "set_bonus", [1])
	c.init(_position, level)
	
func _on_Jumper_captured(object):
	$Camera2D.position = object.position
	object.capture(player)
	call_deferred("spawn_circle")
	self.score += 1 * bonus
	self.bonus += 1
	num_circles += 1
	if num_circles > 0 and num_circles % settings.circles_per_level == 0:
		level += 1
		background.set_background(level)
		$HUD.show_message("Level %s" % str(level))
		if settings.save_dict["enable_sound"]:
				audio_player.stream = LEVEL_UP_SOUND
				audio_player.stream.loop = false
				audio_player.play()
				yield(audio_player, "finished")

func set_score(value):
	$HUD.update_score(score, value)
	score = value
	if score > highscore and !new_highscore:
		$HUD.show_message("New\nRecord!")
		new_highscore = true
	
func _on_Jumper_died():
	if score > highscore:
		highscore = score
		settings.save_dict["highscore"] = score
		settings.save_game()
	get_tree().call_group("circles", "implode")
	Input.vibrate_handheld()
	$Screens.game_over(score, highscore)
	$HUD.hide()
	if settings.save_dict["enable_sound"]:
		audio_player.stream = GAME_OVER_SOUND
		audio_player.stream.loop = false
		audio_player.play()
		yield(audio_player, "finished")

	if settings.save_dict["enable_music"]:
		fade_music()
	yield(get_tree().create_timer(1.0), "timeout")
	if settings.enable_ads:
		if randf() < settings.interstitial_rate:
			if admob.is_interstitial_loaded():
				if unityads.is_rewarded_loaded():
					if randf() < 0.5:
						unityads.show_rewarded()
					else:
						admob.show_interstitial()
				else:
					admob.show_interstitial()
			elif unityads.is_rewarded_loaded():
				unityads.show_rewarded()
			else:
				admob.show_banner()
		else:
			admob.show_banner()

func fade_music():
	$MusicFade.interpolate_property($Music, "volume_db",
			0, -50, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$MusicFade.start()
	yield($MusicFade, "tween_all_completed")
	$Music.stop()

func set_bonus(value):
	bonus = value
	$HUD.update_bonus(bonus)
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		print("go back")
		if $Screens.current_screen == $Screens/TitleScreen:
			get_tree().quit()
		elif $Screens.current_screen: #not playing
			$Screens.change_screen($Screens/TitleScreen)
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
#		print("focus out")
#	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
#		print("focus in")


func _on_Admob_banner_failed_to_load(error_code):
	print("Banner failed to load: Error code " + str(error_code) + "\n")


func _on_Admob_banner_loaded():
	print("Banner loaded\n")


func _on_Admob_interstitial_closed():
	print("Interstitial closed\n")
	admob.load_interstitial()
	if settings.enable_ads:
		admob.show_banner()


func _on_Admob_interstitial_failed_to_load(error_code):
	print("Interstitial failed to load: Error code " + str(error_code) + "\n")


func _on_Admob_interstitial_loaded():
	print("Interstitial loaded\n")


func _on_UnityAds_initialization_completed():
	unityads.load_rewarded()


func _on_UnityAds_rewarded_closed():
	unityads.load_rewarded()
	if settings.enable_ads:
		admob.show_banner()

