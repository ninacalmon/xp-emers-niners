extends Node
## AudioManager (Autoload)
##
## Works with player nodes you pass in: AudioStreamPlayer, AudioStreamPlayer2D
## or AudioStreamPlayer3D (they can be mixed freely).
##
## - Music: play_music() fades the current track out while the new one fades in.
##   stop_music() fades the current one out.
## - Other sounds: play_sound()/stop_sound() fade any player in/out and never
##   touch the music, so they simply overlay on top of it.
##
## The volume_db a player has the first time you pass it here is remembered as
## its target volume. Fades go to/from that value, and after a fade-out the
## volume is restored so the node is ready to be played normally again.
## The manager only plays/stops your nodes, it never frees them.

const DEFAULT_FADE: float = 1.0
const SILENT_LINEAR: float = 0.0001
const BASE_DB_META: StringName = &"audio_manager_base_db"
const FADE_META: StringName = &"audio_manager_fade_tween"

var _current_music: Node = null


# ---------------------------------------------------------------- Music

## Starts `player` as the current music. The previous music (if any) fades out
## while this one fades in (crossfade). Does nothing if it is already the
## current music and playing.
func play_music(player: Node, fade_time: float = DEFAULT_FADE) -> void:
	if not _is_audio_player(player):
		push_warning("AudioManager.play_music(): expected an AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D.")
		return
	if player == _current_music and _is_playing(player):
		return

	var previous: Node = _current_music
	if previous != null and is_instance_valid(previous) and previous != player:
		stop_sound(previous, fade_time)

	_current_music = player
	play_sound(player, fade_time)


## Fades out and stops the current music.
func stop_music(fade_time: float = DEFAULT_FADE) -> void:
	var music: Node = _current_music
	_current_music = null
	if music != null and is_instance_valid(music):
		stop_sound(music, fade_time)


func is_music_playing() -> bool:
	return _current_music != null and is_instance_valid(_current_music) and _is_playing(_current_music)


func get_current_music() -> Node:
	if _current_music != null and is_instance_valid(_current_music):
		return _current_music
	return null


# --------------------------------------------------------------- Sounds

## Plays any player on top of whatever else is playing.
## With fade_time > 0 it fades in. If the player is already playing (for
## example while fading out) it just fades back in, unless `restart` is true.
func play_sound(player: Node, fade_time: float = 0.0, restart: bool = false) -> void:
	if not _is_audio_player(player):
		push_warning("AudioManager.play_sound(): expected an AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D.")
		return

	_remember_base_db(player)
	var base_db: float = _get_base_db(player)

	if restart and _is_playing(player):
		_kill_fade(player)
		player.call(&"stop")

	if fade_time <= 0.0:
		_kill_fade(player)
		_set_volume_db(player, base_db)
		if not _is_playing(player):
			player.call(&"play")
		return

	if not _is_playing(player):
		_set_volume_db(player, linear_to_db(SILENT_LINEAR))
		player.call(&"play")
	_fade_to(player, db_to_linear(base_db), fade_time)


## Fades out and stops any player (music or not).
func stop_sound(player: Node, fade_time: float = DEFAULT_FADE) -> void:
	if not _is_audio_player(player):
		push_warning("AudioManager.stop_sound(): expected an AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D.")
		return

	_remember_base_db(player)
	if not _is_playing(player):
		return

	if fade_time <= 0.0:
		_finish_stop(player)
		return
	_fade_to(player, 0.0, fade_time, _finish_stop.bind(player))


# ------------------------------------------------------------- Internals

func _is_audio_player(node: Node) -> bool:
	if node == null or not is_instance_valid(node):
		return false
	return node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D


func _is_playing(player: Node) -> bool:
	return bool(player.get(&"playing"))


func _get_volume_db(player: Node) -> float:
	return float(player.get(&"volume_db"))


func _set_volume_db(player: Node, volume_db: float) -> void:
	player.set(&"volume_db", volume_db)


func _remember_base_db(player: Node) -> void:
	if not player.has_meta(BASE_DB_META):
		player.set_meta(BASE_DB_META, _get_volume_db(player))


func _get_base_db(player: Node) -> float:
	return float(player.get_meta(BASE_DB_META, _get_volume_db(player)))


func _finish_stop(player: Node) -> void:
	if not is_instance_valid(player):
		return
	_kill_fade(player)
	player.call(&"stop")
	_set_volume_db(player, _get_base_db(player))


## Tweens the player's volume (in linear amplitude, which sounds smoother than
## tweening dB directly) from its current level to `to_linear`.
func _fade_to(player: Node, to_linear: float, time: float, on_done: Callable = Callable()) -> void:
	_kill_fade(player)

	var from_linear: float = db_to_linear(_get_volume_db(player))
	var tween: Tween = create_tween()
	tween.bind_node(player) # killed automatically if the player is freed
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) # keep fading while paused
	player.set_meta(FADE_META, tween)
	tween.tween_method(
		func(value: float) -> void:
			if is_instance_valid(player):
				_set_volume_db(player, linear_to_db(maxf(value, SILENT_LINEAR))),
		from_linear,
		to_linear,
		time
	)
	if on_done.is_valid():
		tween.finished.connect(on_done)


func _kill_fade(player: Node) -> void:
	var old: Variant = player.get_meta(FADE_META, null)
	if old is Tween:
		var old_tween: Tween = old as Tween
		if old_tween.is_valid():
			old_tween.kill()
