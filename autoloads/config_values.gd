extends Node
## ConfigValue's purpose is to estabilish from the start some variables that
## may be controlled by settings options in the future.

## WARNING: ALL script that uses any of the following variables, must 
## connect to the update_config_values signal. <- EXAMPLE CODE IN THE END OF SCRIPT!

@warning_ignore("unused_signal")
signal update_config_values(config_field: ConfigField)

enum ConfigField {CONTROLS, VIDEO}

#region CONTROLS CONFIG VARS
const DEF_h_mouse_sensitivity: float = 0.0035
const DEF_v_mouse_sensitivity: float = 0.002

var h_mouse_sensitivity: float = DEF_h_mouse_sensitivity
var v_mouse_sensitivity: float = DEF_v_mouse_sensitivity
#endregion

#region VIDEO CONFIG VARS
# nothing yet
#endregion

## ===================== EXAMPLE CODE ======================

'''
#region ConfigVariables
var used_controls_var
var used_video_var
#endregion

func _ready() -> void:
	ConfigValues.update_config_values.connect(update_config_values)

func update_config_values(config_field: ConfigValues.ConfigField):

	match config_area:

		ConfigValues.ConfigField.CONTROLS:
			used_controls_var = ConfigValues.used_controls_var

		ConfigValues.ConfigField.VIDEO:
			used_video_var = ConfigValues.used_video_var
'''
