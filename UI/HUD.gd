extends CanvasLayer

onready var rocket1 = $BonusBox/HBoxContainer/Rocket1
onready var rocket2 = $BonusBox/HBoxContainer/Rocket2
onready var rocket3 = $BonusBox/HBoxContainer/Rocket3
onready var tween_rocket = $TweenRocket

var score = 0

func _ready():
	$Message.rect_pivot_offset = $Message.rect_size / 2
	
func show_message(text):
	$Message.text = text
	$MessageAnimation.play("show_message")
	
func hide():
	$ScoreBox.hide()
	$BonusBox.hide()
	$StartTip.hide()
	
func show():
	$ScoreBox.show()
	$BonusBox.show()
	$StartTip.show()
	
func update_score(_score, value):
	if value > 0 and $StartTip.visible:
		$StartTip.hide()
	$Tween.interpolate_property(self, "score", _score,
			value, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$ScoreAnimation.play("score")

func update_bonus(value):
	$BonusBox/Bonus.text = str(value) + "x"
	if value > 1:
		$BonusAnimation.play("bonus")
# only display less 3 rockets
func show_rocket(n:int):
	rocket1.visible = false
	rocket2.visible = false
	rocket3.visible = false
	n = min(3, n)
	match n:
		1:
			rocket1.visible = true
		2:
			rocket1.visible = true
			rocket2.visible = true
		3:
			rocket1.visible = true
			rocket2.visible = true
			rocket3.visible = true

# flash the last rocket
func flash_rocket():
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 1.0, 0.2, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 0.2, 1.0, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.3)
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 1.0, 0.2, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.6)
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 0.2, 1.0, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 0.9)
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 1.0, 0.2, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1.2)
	tween_rocket.interpolate_property(rocket1,  "modulate:a", 0.2, 1.0, 0.3, Tween.TRANS_QUAD, Tween.EASE_IN_OUT, 1.5)
	tween_rocket.start()
	
func _on_Tween_tween_step(object, key, elapsed, value):
	$ScoreBox/HBoxContainer/Score.text = str(int(value))
