extends Control


@onready var sun_animated_spr: AnimatedSprite2D = $MarginContainer/Control/SunAnimatedSpr


func _ready() -> void:
	TimeManager.time_pass.connect(_on_time_pass)

func _on_time_pass(time: TimeManager.Times) -> void:
	var anim: String = ""

	match time:
		TimeManager.Times.at1200:
			anim = "12"
		TimeManager.Times.at1500:
			anim = "12to15"
		TimeManager.Times.at1800:
			anim = "15to18"
		TimeManager.Times.at2100:
			anim = "18to21"
		TimeManager.Times.at2300:
			anim = "21to00"
		TimeManager.Times.at2400:
			anim = "00"

	await get_tree().create_timer(2.5).timeout
	sun_animated_spr.play(anim)
