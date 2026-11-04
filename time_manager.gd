extends Node

var sun: Sun
#var sun_ui: SunUI

enum Times {at1200, at1500, at1800, at2100, at2400}

func _ready() -> void:
	get_tree().get_first_node_in_group("sun")


func set_time(time: Times):
	var sun_current_minutes: int = 720

	match time:
		Times.at1200:
			sun_current_minutes = 720
		Times.at1500:
			sun_current_minutes = 900
		Times.at1800:
			sun_current_minutes = 1080
		Times.at2100:
			sun_current_minutes = 1260
		Times.at2400:
			sun_current_minutes = 1440


# values picked:
	# day length 5
	# sunrise hour: 0
	# sunset hour 5


## hour 1200:
# 120 -> 2 * 60

## hour 1500:
## hour 1800:
## hour 2100:

## hour 2400:
#270.0 - 4.5 * 60
