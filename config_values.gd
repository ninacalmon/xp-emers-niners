extends Node

@warning_ignore("unused_signal")
signal update_config_values(config_area: ConfigArea)

enum ConfigArea {CONTROLS, VIDEO}

const DEF_h_mouse_sensitivity: float = 0.0035
const DEF_v_mouse_sensitivity: float = 0.002

var h_mouse_sensitivity: float = DEF_h_mouse_sensitivity
var v_mouse_sensitivity: float = DEF_v_mouse_sensitivity
