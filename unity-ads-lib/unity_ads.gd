extends Node
class_name UnityAds, "res://unity-ads-lib/icon.png"

# Godot IronSource mobile ad plugin library
# Initializing, Interstitial , Rewarded ads and Banner implementation
# Initializing
signal initialization_completed

# Interstitial signals
signal interstitial_loaded
signal interstitial_opened
signal interstitial_closed

# Rewarded Signals
signal rewarded_loaded
signal rewarded_opened
signal rewarded_closed
signal rewarded #reward the player

# Banner
signal banner_loaded


# Properties
export var _game_id : String = "4759265"
export var _interstitial_id : String = "Interstitial_Android"
export var _rewarded_id : String = "Rewarded_Android"
export var _banner_id : String = "Banner_Android"
export var _is_test_mode : bool = false
export var _banner_on_top : bool = false

# API
func load_interstitial() -> void:
	if is_initialized():
		_unity_ads.loadInterstitail()
		
func show_interstitial() -> void:
	if _unity_ads != null :
		_unity_ads.showInterstitial()

func load_rewarded() -> void:
	if is_initialized():
		_unity_ads.loadRewarded()


func show_rewarded() -> void:
	if _unity_ads != null:
		_unity_ads.showRewarded()


func load_banner() -> void:
	if _unity_ads != null:
		_unity_ads.loadBanner(_banner_on_top)


func show_banner() -> void:
	if _unity_ads != null:
		_unity_ads.showBanner()


func hide_banner() -> void:
	if _unity_ads != null:
		_unity_ads.hideBanner()

func is_rewarded_loaded() -> bool:
	return is_ad_loaded(_rewarded_id)

func is_banner_loaded() -> bool:
	return is_ad_loaded(_banner_id)

func is_interstitial_loaded() -> bool:
	return is_ad_loaded(_interstitial_id)


func is_initialized() -> bool:
	if _unity_ads:
		return _unity_ads.isInitialized()
	else: 
		return false

###################### inner ########################################

var _unity_ads : Object = null


func _ready() -> void:
	yield(owner, "ready")
	if not _initialize():
		printerr("GodotUnityAds Plugin not found, Android Only")

func _initialize() -> bool:
	if Engine.has_singleton("GodotUnityAds"):
		_unity_ads = Engine.get_singleton("GodotUnityAds")
		if not _unity_ads.is_connected("on_interstitial_loaded",self,"_on_interstitial_loaded"):
			_connect_signals()
		_unity_ads.initialize(_game_id, _interstitial_id, _rewarded_id, _banner_id , _is_test_mode)
		return true
	return false


func _connect_signals() -> void:
	# Initializing
	_unity_ads.connect("on_initialization_complete",self,"_on_initialization_complete")
	# Interstitial
	_unity_ads.connect("on_interstitial_loaded",self,"_on_interstitial_loaded")
	_unity_ads.connect("on_interstitial_opened",self,"_on_interstitial_opened")
	_unity_ads.connect("on_interstitial_closed",self,"_on_interstitial_closed")
	# Rewarded
	_unity_ads.connect("on_rewarded_loaded",self,"_on_rewarded_loaded")
	_unity_ads.connect("on_rewarded_opened",self,"_on_rewarded_opened")
	_unity_ads.connect("on_rewarded_closed",self,"_on_rewarded_closed")
	_unity_ads.connect("on_rewarded",self,"_on_rewarded")
	# Banner
	_unity_ads.connect("on_banner_loaded",self,"_on_banner_loaded")

func _on_initialization_complete():
	emit_signal("initialization_completed")

func _on_interstitial_loaded() -> void:
	emit_signal("interstitial_loaded")

func _on_interstitial_opened() -> void:
	emit_signal("interstitial_opened")

func _on_interstitial_closed() -> void:
	emit_signal("interstitial_closed")

func _on_rewarded_loaded() -> void:
	emit_signal("rewarded_loaded")

func _on_rewarded_opened() -> void:
	emit_signal("rewarded_opened")

func _on_rewarded_closed() -> void:
	emit_signal("rewarded_closed")

func _on_rewarded() -> void:
	emit_signal("rewarded")

func _on_banner_loaded() -> void:
	emit_signal("banner_loaded")

func is_ad_loaded(ad_id : String) -> bool:
	if _unity_ads != null:
		return _unity_ads.isAdLoaded(ad_id)
	return false
