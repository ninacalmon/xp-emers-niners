extends Control

@onready var frame_animated_spr: AnimatedSprite2D = $FrameAnimatedSpr
@onready var player_speech_overlay_animated_spr: AnimatedSprite2D = $PlayerSpeechOverlayAnimatedSpr
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var _frame: PanelAnimator
var _overlay: PanelAnimator
var _balloon: DialogueManagerExampleBalloon

## Kept for any external scripts that read it.
var is_player_talking: bool:
	get:
		return _overlay != null and _overlay.state in [PanelAnimator.State.OPENING, PanelAnimator.State.OPEN]


func _ready() -> void:
	rich_text_label.hide()
	player_speech_overlay_animated_spr.hide()

	_frame = PanelAnimator.new(frame_animated_spr, &"dialogue", &"default", false)
	_overlay = PanelAnimator.new(player_speech_overlay_animated_spr, &"dialogue", &"", true)
	frame_animated_spr.play(&"default")

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.balloon_started.connect(_on_balloon_started)
	DialogueManager.got_dialogue.connect(_on_got_dialogue)
	PuzzleManager.puzzle_started.connect(_on_puzzle_started)


func _on_dialogue_started(_res: DialogueResource) -> void:
	await _frame.open()
	# Always yield one frame so the balloon is already awaiting ready_to_start,
	# even if the frame was already open and open() returned instantly.
	await get_tree().process_frame
	DialogueManager.ready_to_start.emit()
	if _frame.state == PanelAnimator.State.OPEN:
		rich_text_label.show()


func _on_dialogue_ended(_res: DialogueResource) -> void:
	rich_text_label.hide()
	_overlay.close()
	_frame.close()


func _on_got_dialogue(_line: DialogueLine) -> void:
	show()
	# The text only appears once the frame is fully open (re-opens it if a puzzle closed it).
	var is_open: bool = await _frame.open()
	if is_open:
		rich_text_label.show()


func _on_puzzle_started(_lock_player_movement: bool) -> void:
	# Does nothing if no dialogue frame is open, so no stray reverse animation.
	rich_text_label.hide()
	_overlay.close()
	_frame.close()


func _on_balloon_started(balloon: Node) -> void:
	if not balloon is DialogueManagerExampleBalloon:
		return
	if is_instance_valid(_balloon):
		if _balloon.player_line_started.is_connected(_on_player_line_started):
			_balloon.player_line_started.disconnect(_on_player_line_started)
		if _balloon.player_line_ended.is_connected(_on_player_line_ended):
			_balloon.player_line_ended.disconnect(_on_player_line_ended)

	_balloon = balloon as DialogueManagerExampleBalloon
	_balloon.player_line_started.connect(_on_player_line_started)
	_balloon.player_line_ended.connect(_on_player_line_ended)


func _on_player_line_started() -> void:
	var balloon: DialogueManagerExampleBalloon = _balloon
	await _overlay.open()
	# Same reason as above: never emit synchronously.
	await get_tree().process_frame
	# Every started line gets exactly one ready_to_start, so the balloon can't hang.
	if is_instance_valid(balloon):
		balloon.ready_to_start.emit()


func _on_player_line_ended() -> void:
	_overlay.close()


## Drives one AnimatedSprite2D through CLOSED -> OPENING -> OPEN -> CLOSING.
## Each transition gets a token; if something supersedes it, the old coroutine
## exits without touching anything.
class PanelAnimator extends RefCounted:
	enum State { CLOSED, OPENING, OPEN, CLOSING }

	signal settled

	var state: State = State.CLOSED

	var _sprite: AnimatedSprite2D
	var _anim: StringName
	var _idle_anim: StringName
	var _hide_when_closed: bool
	var _token: int = 0


	func _init(sprite: AnimatedSprite2D, anim: StringName, idle_anim: StringName, hide_when_closed: bool) -> void:
		_sprite = sprite
		_anim = anim
		_idle_anim = idle_anim
		_hide_when_closed = hide_when_closed
		# A looping animation never emits animation_finished, which would hang everything.
		if _can_play():
			_sprite.sprite_frames.set_animation_loop(_anim, false)


	## Returns true if the panel ended up fully open.
	func open() -> bool:
		if state == State.OPEN:
			return true
		if state == State.OPENING:
			await settled
			return state == State.OPEN
		if not _can_play():
			state = State.OPEN
			return true

		_token += 1
		var token: int = _token
		state = State.OPENING
		_sprite.show()
		# From CLOSING this continues from the current frame; from CLOSED it starts at frame 0.
		_sprite.play(_anim, 1.0, false)

		await _sprite.animation_finished
		if token != _token or not is_instance_valid(_sprite):
			return false  # superseded; whoever superseded us already emitted settled

		state = State.OPEN
		settled.emit()
		return true


	func close() -> void:
		if state == State.CLOSED or state == State.CLOSING:
			return
		if not _can_play():
			state = State.CLOSED
			return

		var was_open: bool = state == State.OPEN
		var was_opening: bool = state == State.OPENING
		_token += 1
		var token: int = _token
		state = State.CLOSING
		if was_opening:
			settled.emit()  # release anyone waiting on open()

		# From OPEN start at the last frame; from OPENING reverse from the current frame.
		_sprite.play(_anim, -1.0, was_open)

		await _sprite.animation_finished
		if token != _token or not is_instance_valid(_sprite):
			return

		state = State.CLOSED
		if _idle_anim != &"":
			_sprite.play(_idle_anim)
		if _hide_when_closed:
			_sprite.hide()
		settled.emit()


	func _can_play() -> bool:
		if not is_instance_valid(_sprite) or _sprite.sprite_frames == null:
			return false
		if not _sprite.sprite_frames.has_animation(_anim):
			push_warning("PanelAnimator: missing animation '%s' on %s" % [_anim, _sprite.name])
			return false
		return true
