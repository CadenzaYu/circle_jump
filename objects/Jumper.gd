extends Area2D

signal captured
signal died

onready var trail = $Trail/Points

var rocket = preload("res://assets/images/rocket.png")
var launch = preload("res://assets/images/launch.png")

var velocity = Vector2(100, 0)
var jump_speed = 1500
var target = null
var trail_length = 25

func _ready():
	$Sprite.texture = rocket
	var trail_color = settings.theme["player_trail"]
	trail.gradient.set_color(1, trail_color)
	trail_color.a = 0
	trail.gradient.set_color(0, trail_color)
	
func _unhandled_input(event):
	if target and event is InputEventScreenTouch and event.pressed:
		jump()
		
func jump():
	target.implode()
	target = null
	$Sprite.texture = launch
	velocity = transform.x * jump_speed
	if settings.save_dict["enable_sound"]:
		$Jump.play()

func _on_Jumper_area_entered(area):
	target = area
	velocity = Vector2.ZERO
	emit_signal("captured", area)
	$Sprite.texture = rocket
	if settings.save_dict["enable_sound"]:
		$Capture.play()
	
func _physics_process(delta):
	if trail.points.size() > trail_length:
		trail.remove_point(0)
	trail.add_point(position)
	
	if target:
		transform = target.orbit_position.global_transform
	else:
		position += velocity * delta
		
func die():
	target = null
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	if !target:
		emit_signal("died")
		die()
