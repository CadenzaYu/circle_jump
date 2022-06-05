extends Node

const LEVEL_UP_SOUND = preload("res://assets/audio/level_up.ogg")
const GAME_OVER_SOUND = preload("res://assets/audio/game_over.ogg")
const NEW_HIGHSCORE_SOUND = preload("res://assets/audio/new_highscore.ogg")
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
		admob.banner_id = "ca-app-pub-3940256099942544/6300978111"
		admob.interstitial_id = "ca-app-pub-3940256099942544/1033173712"
		admob.rewarded_id = "ca-app-pub-3940256099942544/5224354917"
		admob.rewarded_interstitial_id = "ca-app-pub-3940256099942544/5354046379"
		admob.is_real = false
		unityads._is_test_mode = true
		settings.save_dict["life"] = 2
		settings.interstitial_rate = 1.0
		
	settings.admob = admob
	randomize()
	highscore = settings.save_dict["highscore"]
	$HUD.hide()
	
func new_game():
	new_highscore = false
	admob.hide_banner()
	self.score = 0
	self.bonus = 0
	num_circles = 0
	level = 1
	background.set_background(level)
	$HUD.update_score(score, 0)
	$HUD.show_rocket(settings.save_dict["life"])
	$Camera2D.position = $StartPosition.position
	new_player($StartPosition.position)
	spawn_circle($StartPosition.position)
	$HUD.show()
	$HUD.show_message("Go!")
	if settings.save_dict["enable_music"]:
		$Music.volume_db = 0
		$Music.play()

func new_player(_position = $StartPosition.position):
	player = Jumper.instance()
	player.position = _position
	add_child(player)
	player.connect("captured", self, "_on_Jumper_captured")
	player.connect("died", self, "_on_Jumper_died")
		
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
		if settings.save_dict["enable_sound"]:
			audio_player.stream = NEW_HIGHSCORE_SOUND
			audio_player.stream.loop = false
			audio_player.play()
			yield(audio_player, "finished")
	
func _on_Jumper_died():
	if OS.get_name() == "Android":
		Input.vibrate_handheld()
	# if has lives
	if settings.save_dict["life"] > 0:
		settings.save_dict["life"] -= 1
		settings.save_game()
		$HUD.flash_rocket()
		yield($HUD.tween_rocket, "tween_all_completed")
		$HUD.show_rocket(settings.save_dict["life"])
		var _pos = Vector2(0, 1000)
		for a_child in get_children():
			if is_instance_valid(a_child) and "Circle" in a_child.name:
				if a_child.position.y < _pos.y:
					_pos =  a_child.position
		new_player(_pos)
	else:
		if score > highscore:
			highscore = score
			settings.save_dict["highscore"] = score
			settings.save_game()
		get_tree().call_group("circles", "implode")
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
				if admob.is_rewarded_interstitial_loaded():
					if unityads.is_rewarded_loaded():
						if randf() < 0.5:
							unityads.show_rewarded()
						else:
							admob.show_rewarded_interstitial()
					else:
						admob.show_rewarded_interstitial()
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


func _on_Admob_initialization_complete(status, adapter_name):
	print("Admob_initialization_complete：%d, " %status + adapter_name)
	if status == admob.INITIALIZATION_STATUS.READY:
		admob.load_banner()
		#admob.load_interstitial()
		admob.load_rewarded_interstitial()

func _on_Admob_banner_failed_to_load(error_code):
	print("Banner failed to load: Error code " + str(error_code) + "\n")

func _on_Admob_banner_loaded():
	print("Banner loaded\n")
	if settings.enable_ads:
		admob.show_banner()

func _on_Admob_banner_closed():
	print("Admob_banner_closed\n")
	admob.load_banner()
	if settings.enable_ads:
		admob.show_banner()

func _on_Admob_interstitial_closed():
	print("Admob_Interstitial closed\n")
	admob.load_interstitial()
	if settings.enable_ads:
		admob.show_banner()

func _on_Admob_interstitial_failed_to_load(error_code):
	print("Interstitial failed to load: Error code " + str(error_code) + "\n")

func _on_Admob_interstitial_loaded():
	print("Interstitial loaded\n")

func _on_Admob_rewarded_interstitial_ad_loaded():
	print("Admob_rewarded_interstitial_ad_loaded\n")

func _on_Admob_rewarded_interstitial_ad_closed():
	admob.load_rewarded_interstitial()
	if settings.enable_ads:
		admob.show_banner()

func _on_Admob_user_earned_rewarded(currency, amount):
	#assert(currency == "life")
	print("currency: %s "  % currency, "amount=%d" % amount)
	settings.save_dict["life"] += amount
	settings.save_game()

func _on_Admob_rewarded_interstitial_ad_opened():
	print("Admob_rewarded_interstitial_ad_opened\n")

func _on_UnityAds_initialization_completed():
	unityads.load_rewarded()

func _on_UnityAds_rewarded_closed():
	unityads.load_rewarded()
	if settings.enable_ads:
		admob.show_banner()

func _on_UnityAds_rewarded():
	print("UnityAds_rewarded")
	settings.save_dict["life"] += 1
	settings.save_game()

func _on_UnityAds_rewarded_loaded():
	print("UnityAds_rewarded_loaded\n")


func _on_Admob_banner_opened():
	print("_on_Admob_banner_opened\n")


func _on_Admob_banner_destroyed():
	print("_on_Admob_banner_destroyed\n")


func _on_Admob_banner_clicked():
	print("_on_Admob_banner_clicked\n")
