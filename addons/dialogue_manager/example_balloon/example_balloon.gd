class_name DialogueManagerExampleBalloon extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

signal line_finished(line: DialogueLine)

signal ready_to_start

signal player_line_started

signal player_line_ended

@export_color_no_alpha var player_color: Color

## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given cue when using balloon as a [Node] in a scene.
@export var start_from_cue: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"skip_dialogue"

## If the player is allowed to skip the typing of the dialogue
@export var can_skip: bool = true

## If lines should advance on their own after finishing typing
@export var auto_advance: bool = false

## Seconds to wait after a line finishes typing before auto advancing
@export var auto_advance_delay: float = 1.5

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

var default_progress_color: Color

var is_player_themed: bool = false

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Polygon2D = %Progress


func _ready() -> void:
	default_progress_color = progress.color

	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	PuzzleManager.puzzle_started.connect(_on_puzzle_started)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()

	## EXAMPLE MESSAGE
	#var warning: Button = Button.new()
	#warning.text = DMConstants.translate("This is an example balloon. Create your own balloon in 'Project > Tools > Dialogue > Create Balloon...'")
	#warning.disabled = true
	#warning.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	#balloon.add_child(warning)
	#balloon.move_child(warning, 0)
	## /EXAMPLE MESSAGE


func _on_puzzle_started(_lock_player_movement: bool) -> void:
	is_waiting_for_input = false
	balloon.hide()

func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice")


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = []) -> void:

	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	show()


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	var is_current_line_player: bool = is_player_line(dialogue_line)

	if is_current_line_player:
		player_line_started.emit()
		if not is_player_themed:
			await ready_to_start
			player_theme(true)

	if is_player_themed and not is_current_line_player:
		player_theme(false)
		player_line_ended.emit()

	character_label.visible = true
	if not dialogue_line.character:
		dialogue_line.character = " "
	character_label.text = tr(dialogue_line.character, "dialogue")

	if dialogue_line.character in wobbly_characters and not dialogue_line.text.begins_with("[shake"):
		dialogue_line.text = apply_wobbly_effect(dialogue_line.text)

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	line_finished.emit(dialogue_line)

	# Wait for next line
	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()

		if auto_advance:
			var current_line: DialogueLine = dialogue_line
			await get_tree().create_timer(auto_advance_delay).timeout

			if dialogue_line == current_line:
				next(dialogue_line.responses[0].next_id)
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		if auto_advance:
			is_waiting_for_input = false
			balloon.focus_mode = Control.FOCUS_NONE
			var current_line: DialogueLine = dialogue_line
			await get_tree().create_timer(auto_advance_delay).timeout
			# Only advance if nothing else changed the line while we waited
			if dialogue_line == current_line:
				next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			if can_skip:
				dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion


func player_theme(_bool: bool):
	if _bool:
		character_label.add_theme_color_override("default_color", player_color)
		dialogue_label.add_theme_color_override("default_color", player_color)

		progress.color = player_color

		is_player_themed = true

	else:
		if character_label.has_theme_color_override("default_color"):
			character_label.remove_theme_color_override("default_color")

		if dialogue_label.has_theme_color_override("default_color"):
			dialogue_label.remove_theme_color_override("default_color")

		progress.color = default_progress_color

		is_player_themed = false



## a player line is either spoken by "Você" or has no character at all.
func is_player_line(line: DialogueLine) -> bool:
	return line.character == "Você" or line.character.is_empty()


## Blocks (or allows) skipping the typing of the dialogue.
func set_skip_blocked(blocked: bool) -> void:
	can_skip = not blocked


## Enables (or disables) automatically passing to the next line.
func set_auto_advance(enabled: bool, delay: float = 1.5) -> void:
	auto_advance = enabled
	auto_advance_delay = delay



## Characters whose lines get the "alternating size + shake" effect.
@export var wobbly_characters: Array[String] = ["Abade"]
@export var small_size: int = 27
@export var big_size: int = 45
@export var small_group_length: int = 3
@export var big_group_length: int = 2
@export var shake_rate: float = 20.0
@export var shake_level: int = 5
## Chance (0.0 to 1.0) that a letter becomes bold / italic. They roll independently,
## so a letter can be both.
@export_range(0.0, 1.0) var bold_chance: float = 0.2
@export_range(0.0, 1.0) var italic_chance: float = 0.2

@export var force_uppercase_letters: Array[String] = ["l"]

@export var big_sentence_start: bool = true


## Randomly wraps a single letter in [b] and/or [i].
func _style_letter(letter: String) -> String:
	var styled: String = letter
	var is_bold: bool = randf() < bold_chance
	var is_italic: bool = randf() < italic_chance

	if is_bold:
		styled = "[b]%s[/b]" % styled
	if is_italic:
		styled = "[i]%s[/i]" % styled

	return styled

## Wraps the text so letters alternate between small/big groups, all inside a [shake].
## Existing BBCode tags are kept intact and don't count as letters.
func apply_wobbly_effect(text: String) -> String:
	var result: String = ""
	var in_small_group: bool = true
	var letters_in_group: int = 0
	var group_open: bool = false
	var is_sentence_start: bool = true
	var i: int = 0

	while i < text.length():
		var current_char: String = text[i]

		# Tag BBCode já existente: fecha a nossa, emite a deles, reabre a nossa
		if current_char == "[":
			var tag_end: int = text.find("]", i)
			if tag_end == -1:
				tag_end = text.length() - 1
			var tag: String = text.substr(i, tag_end - i + 1)
			if group_open:
				result += "[/font_size]"
			result += tag
			if group_open:
				result += _get_size_open_tag(in_small_group)
			i = tag_end + 1
			continue

		# Espaços são mantidos, mas não contam como letra
		if current_char.strip_edges().is_empty():
			result += current_char
			i += 1
			continue

		# Letras forçadas para maiúscula (ex: "l" -> "L")
		if current_char in force_uppercase_letters:
			current_char = current_char.to_upper()

		var is_letter: bool = current_char.to_lower() != current_char.to_upper()

		# Primeira letra da frase nunca pequena: se estiver num grupo pequeno,
		# fecha esse grupo e começa um grande
		if big_sentence_start and is_sentence_start and is_letter:
			if group_open and in_small_group:
				result += "[/font_size]"
				group_open = false
			if not group_open:
				in_small_group = false
				letters_in_group = 0

		if not group_open:
			result += _get_size_open_tag(in_small_group)
			group_open = true

		result += _style_letter(current_char)
		letters_in_group += 1

		var group_length: int = small_group_length if in_small_group else big_group_length
		if letters_in_group >= group_length:
			result += "[/font_size]"
			group_open = false
			in_small_group = not in_small_group
			letters_in_group = 0

		# Atualiza o estado de "início de frase"
		if current_char in [".", "!", "?"]:
			is_sentence_start = true
		elif is_letter:
			is_sentence_start = false

		i += 1

	if group_open:
		result += "[/font_size]"

	return "[shake rate=%s level=%s]%s[/shake]" % [shake_rate, shake_level, result]


func _get_size_open_tag(is_small: bool) -> String:
	var size: int = small_size if is_small else big_size
	return "[font_size=%d]" % size
