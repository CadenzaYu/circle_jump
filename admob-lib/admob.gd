extends Node

class_name AdMob, "res://admob-lib/icon.png"

# signals
signal initialization_complete(status, adapter_name)

signal banner_loaded()
signal banner_failed_to_load(error_code)
signal banner_opened()
signal banner_clicked()
signal banner_closed()
signal banner_recorded_impression()
signal banner_destroyed()

signal interstitial_failed_to_load(error_code)
signal interstitial_loaded()
signal interstitial_closed()
signal interstitial_failed_to_show(error_code)
signal interstitial_opened()

signal rewarded_ad_failed_to_load(error_code)
signal rewarded_ad_loaded()
signal rewarded_ad_failed_to_show(error_code)
signal rewarded_ad_opened()
signal rewarded_ad_closed()

signal rewarded_interstitial_ad_failed_to_load(error_code)
signal rewarded_interstitial_ad_loaded()
signal rewarded_interstitial_ad_failed_to_show(error_code)
signal rewarded_interstitial_ad_opened()
signal rewarded_interstitial_ad_closed()

signal user_earned_rewarded(currency, amount)

# properties
export var is_real:bool setget is_real_set
export var banner_on_top:bool = true
export(String, "ADAPTIVE_BANNER", "SMART_BANNER", "BANNER", "LARGE_BANNER", "MEDIUM_RECTANGLE", "FULL_BANNER", "LEADERBOARD") var banner_size = "ADAPTIVE_BANNER"
export var banner_id:String
export var interstitial_id:String
export var rewarded_id:String
export var rewarded_interstitial_id:String
export var child_directed:bool = false
export(String, "G", "PG", "T", "MA") var max_ad_content_rate = "PG"
enum INITIALIZATION_STATUS {NOT_READY, READY}

# APIs
# load

func load_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.load_banner(banner_id, banner_on_top, banner_size, false)  # not show_instantly

func load_interstitial() -> void:
	if _admob_singleton != null:
		_admob_singleton.load_interstitial(interstitial_id)
		
func is_interstitial_loaded() -> bool:
	if _admob_singleton != null:
		return _admob_singleton.get_is_interstitial_loaded()
	return false
		
func load_rewarded_video() -> void:
	if _admob_singleton != null:
		_admob_singleton.load_rewarded(rewarded_id)
		
func is_rewarded_video_loaded() -> bool:
	if _admob_singleton != null:
		return _admob_singleton.get_is_rewarded_loaded()
	return false

func load_rewarded_interstitial() -> void:
	if _admob_singleton:
		_admob_singleton.load_rewarded_interstitial(rewarded_interstitial_id)
		
func is_rewarded_interstitial_loaded() -> bool:
	if _admob_singleton:
		return _admob_singleton.get_is_rewarded_interstitial_loaded()
	return false


# show / hide

func show_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.show_banner()
		
func hide_banner() -> void:
	if _admob_singleton != null:
		_admob_singleton.hide_banner()

func show_interstitial() -> void:
	if _admob_singleton != null:
		_admob_singleton.show_interstitial()
		
func show_rewarded() -> void:
	if _admob_singleton != null:
		_admob_singleton.show_rewarded()
		
func show_rewarded_interstitial() -> void:
	if _admob_singleton:
		_admob_singleton.show_rewarded_interstitial()

# destroy
func banner_destroy() -> void:
	if _admob_singleton != null:
		_admob_singleton.destroy_banner()
		
# dimension
func get_banner_dimension() -> Vector2:
	if _admob_singleton != null:
		return Vector2(_admob_singleton.get_banner_width(), _admob_singleton.get_banner_height())
	return Vector2.ZERO

############### inner ############

func _ready():
	yield(owner, "ready")
	if not init():
		printerr("AdMob Java Singleton not found. This plugin will only work on Android")

# setters
func is_real_set(new_val) -> void:
	is_real = new_val
	
func child_directed_set(new_val) -> void:
	child_directed = new_val

func max_ad_content_rate_set(new_val) -> void:
	if new_val != "G" and new_val != "PG" \
		and new_val != "T" and new_val != "MA":
			
		max_ad_content_rate = "G"
		print("Invalid max_ad_content_rate, using 'G'")

# "private" properties
var _admob_singleton = null

# initialization
func init() -> bool:
	if(Engine.has_singleton("AdMob")):
		_admob_singleton = Engine.get_singleton("AdMob")

		# check if one signal is already connected
		if not _admob_singleton.is_connected("initialization_complete", self, "_on_AdMob_initialization_complete"):
			_connect_signals()
		# if already initialized, do nothing
		_admob_singleton.initialize(child_directed, max_ad_content_rate, is_real, false)  #set to not test GDPR
		return true
	return false

# connect the AdMob Java signals
func _connect_signals() -> void:
	_admob_singleton.connect("initialization_complete", self, "_on_AdMob_initialization_complete")

	_admob_singleton.connect("consent_form_dismissed", self, "_on_AdMob_consent_form_dismissed")
	_admob_singleton.connect("consent_status_changed", self, "_on_AdMob_consent_status_changed")
	_admob_singleton.connect("consent_form_load_failure", self, "_on_AdMob_consent_form_load_failure")
	_admob_singleton.connect("consent_info_update_success", self, "_on_AdMob_consent_info_update_success")
	_admob_singleton.connect("consent_info_update_failure", self, "_on_AdMob_consent_info_update_failure")

	_admob_singleton.connect("banner_loaded", self, "_on_AdMob_banner_loaded")
	_admob_singleton.connect("banner_failed_to_load", self, "_on_AdMob_banner_failed_to_load")
	_admob_singleton.connect("banner_opened", self, "_on_AdMob_banner_opened")
	_admob_singleton.connect("banner_clicked", self, "_on_AdMob_banner_clicked")
	_admob_singleton.connect("banner_closed", self, "_on_AdMob_banner_closed")
	_admob_singleton.connect("banner_recorded_impression", self, "_on_AdMob_banner_recorded_impression")
	_admob_singleton.connect("banner_destroyed", self, "_on_AdMob_banner_destroyed")

	_admob_singleton.connect("interstitial_failed_to_load", self, "_on_AdMob_interstitial_failed_to_load")
	_admob_singleton.connect("interstitial_loaded", self, "_on_AdMob_interstitial_loaded")
	_admob_singleton.connect("interstitial_failed_to_show", self, "_on_AdMob_interstitial_failed_to_show")
	_admob_singleton.connect("interstitial_opened", self, "_on_AdMob_interstitial_opened")
	_admob_singleton.connect("interstitial_closed", self, "_on_AdMob_interstitial_closed")

	_admob_singleton.connect("rewarded_ad_failed_to_load", self, "_on_AdMob_rewarded_ad_failed_to_load")
	_admob_singleton.connect("rewarded_ad_loaded", self, "_on_AdMob_rewarded_ad_loaded")
	_admob_singleton.connect("rewarded_ad_failed_to_show", self, "_on_AdMob_rewarded_ad_failed_to_show")
	_admob_singleton.connect("rewarded_ad_opened", self, "_on_AdMob_rewarded_ad_opened")
	_admob_singleton.connect("rewarded_ad_closed", self, "_on_AdMob_rewarded_ad_closed")

	_admob_singleton.connect("rewarded_interstitial_ad_failed_to_load", self, "_on_AdMob_rewarded_interstitial_ad_failed_to_load")
	_admob_singleton.connect("rewarded_interstitial_ad_loaded", self, "_on_AdMob_rewarded_interstitial_ad_loaded")
	_admob_singleton.connect("rewarded_interstitial_ad_failed_to_show", self, "_on_AdMob_rewarded_interstitial_ad_failed_to_show")
	_admob_singleton.connect("rewarded_interstitial_ad_opened", self, "_on_AdMob_rewarded_interstitial_ad_opened")
	_admob_singleton.connect("rewarded_interstitial_ad_closed", self, "_on_AdMob_rewarded_interstitial_ad_closed")

	_admob_singleton.connect("user_earned_rewarded", self, "_on_AdMob_user_earned_rewarded")

	

# callbacks

func _on_AdMob_initialization_complete(status : int, adapter_name : String) -> void:
	emit_signal("initialization_complete", status, adapter_name)

func _on_AdMob_consent_form_dismissed() -> void:
	print("consent_form_dismissed")
func _on_AdMob_consent_status_changed(consent_status_message : String) -> void:
	print("consent_status_changed", consent_status_message)
func _on_AdMob_consent_form_load_failure(error_code : int, error_message: String) -> void:
	print("consent_form_load_failure", error_code, error_message)
func _on_AdMob_consent_info_update_success(consent_status_message : String) -> void:
	print("consent_info_update_success", consent_status_message)
func _on_AdMob_consent_info_update_failure(error_code : int, error_message : String) -> void:
	print("consent_info_update_failure", error_code, error_message)

func _on_AdMob_banner_loaded() -> void:
	emit_signal("banner_loaded")
func _on_AdMob_banner_failed_to_load(error_code : int) -> void:
	emit_signal("banner_failed_to_load", error_code)
func _on_AdMob_banner_opened() -> void:
	emit_signal("banner_opened")
func _on_AdMob_banner_clicked() -> void:
	emit_signal("banner_clicked")
func _on_AdMob_banner_closed() -> void:
	emit_signal("banner_closed")
func _on_AdMob_banner_recorded_impression() -> void:
	emit_signal("banner_recorded_impression")
func _on_AdMob_banner_destroyed() -> void:
	emit_signal("banner_destroyed")

func _on_AdMob_interstitial_failed_to_load(error_code : int) -> void:
	emit_signal("interstitial_failed_to_load", error_code)
func _on_AdMob_interstitial_loaded() -> void:
	emit_signal("interstitial_loaded")
func _on_AdMob_interstitial_failed_to_show(error_code : int) -> void:
	emit_signal("interstitial_failed_to_show", error_code)
func _on_AdMob_interstitial_opened() -> void:
	emit_signal("interstitial_opened")
func _on_AdMob_interstitial_closed() -> void:
	emit_signal("interstitial_closed")

func _on_AdMob_rewarded_ad_failed_to_load(error_code : int) -> void:
	emit_signal("rewarded_ad_failed_to_load", error_code)
func _on_AdMob_rewarded_ad_loaded() -> void:
	emit_signal("rewarded_ad_loaded")
func _on_AdMob_rewarded_ad_failed_to_show(error_code : int) -> void:
	emit_signal("rewarded_ad_failed_to_show", error_code)
func _on_AdMob_rewarded_ad_opened() -> void:
	emit_signal("rewarded_ad_opened")
func _on_AdMob_rewarded_ad_closed() -> void:
	emit_signal("rewarded_ad_closed")

func _on_AdMob_rewarded_interstitial_ad_failed_to_load(error_code : int) -> void:
	emit_signal("rewarded_interstitial_ad_failed_to_load", error_code)
func _on_AdMob_rewarded_interstitial_ad_loaded() -> void:
	emit_signal("rewarded_interstitial_ad_loaded")
func _on_AdMob_rewarded_interstitial_ad_failed_to_show(error_code : int) -> void:
	emit_signal("rewarded_interstitial_ad_failed_to_show", error_code)
func _on_AdMob_rewarded_interstitial_ad_opened() -> void:
	emit_signal("rewarded_interstitial_ad_opened")
func _on_AdMob_rewarded_interstitial_ad_closed() -> void:
	emit_signal("rewarded_interstitial_ad_closed")

func _on_AdMob_user_earned_rewarded(currency : String, amount : int) -> void:
	emit_signal("user_earned_rewarded", currency, amount)


