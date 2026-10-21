extends Node

## [given, completed]

class JulioData:
	var quest_status: Dictionary = {
			"key_for_julio" : [false, false]
		}

	var key_needed: ItemRes = preload("res://resources/itens/test_key.tres")

class LucioData:
	var quests_given: Dictionary = {
			"" : [false, false]
		}


var Julio: JulioData = JulioData.new()
var Lucio: LucioData = LucioData.new()
