class_name AudioManager
extends Node
## Plays the looping ambient (sea and cicadas), the tank engine rumble whose pitch follows the
## tank's speed, and the cannon shot and explosion one-shots;
## owns the master volume and the mute state.
## Implements: design/game-brief.md, MVP feature 7 (story-007-visual-ghibli-e-som).
##
## Listens only to Cannon.fired, Cannon.projectile_impacted and Tank.speed_changed; knows
## nothing of destruction.
## Web: browsers keep audio locked until a user gesture, so on the Web build the ambient starts
## on the first key, mouse, touch or gamepad press instead of at load. Elsewhere it starts at
## once. Mute is the Master bus mute, so it does not depend on any on-screen control.
## Desktop key: M (action "audio_mute").

## Emitted when the mute state changes.
signal mute_changed(muted: bool)

## Cannon whose shots and impacts are heard.
@export var cannon: Cannon
## Tank whose speed drives the engine sound.
@export var tank: Tank
## Audio tuning (see audio_tuning.gd / audio_tuning.tres).
@export var tuning: AudioTuning
## Wait for the first input before starting audio. Forced on in Web builds; exposed so the
## gesture path can be exercised on desktop.
@export var wait_for_gesture: bool = false

var _ambient: AudioStreamPlayer
var _engine: AudioStreamPlayer
var _speed_ratio: float = 0.0
var _engine_level: float = 0.0
var _voices: Array[AudioStreamPlayer] = []
var _next_voice: int = 0
var _shot: AudioStream
var _explosion: AudioStream
var _unlocked: bool = false


func _ready() -> void:
	_register_input_actions()
	AudioServer.set_bus_volume_db(0, linear_to_db(tuning.master_volume))

	_ambient = _make_loop(tuning.ambient_path)
	_ambient.volume_db = tuning.ambient_db
	_engine = _make_loop(tuning.engine_path)
	_apply_engine_level()
	tank.speed_changed.connect(_on_tank_speed_changed)

	_shot = load(tuning.shot_path)
	_explosion = load(tuning.explosion_path)
	for i: int in tuning.one_shot_voices:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)

	cannon.fired.connect(_play_one_shot.bind(_shot, tuning.shot_db))
	cannon.projectile_impacted.connect(_on_projectile_impacted)

	if OS.has_feature("web"):
		wait_for_gesture = true
	if not wait_for_gesture:
		_unlock()


## True while sound is muted.
func is_muted() -> bool:
	return AudioServer.is_bus_mute(0)


## Mutes or unmutes everything (Master bus) and emits mute_changed on a change.
func set_muted(muted: bool) -> void:
	if muted == is_muted():
		return
	AudioServer.set_bus_mute(0, muted)
	mute_changed.emit(muted)


## Flips the mute state.
func toggle_mute() -> void:
	set_muted(not is_muted())


## True once audio has been started (immediately, or after the first input gesture on Web).
func is_unlocked() -> bool:
	return _unlocked


## Current engine playback pitch.
func get_engine_pitch() -> float:
	return _engine.pitch_scale


## True while the ambient loop is playing.
func is_ambient_playing() -> bool:
	return _ambient.playing


## Number of one-shot voices playing now (never above tuning.one_shot_voices).
func get_active_voice_count() -> int:
	var count: int = 0
	for voice: AudioStreamPlayer in _voices:
		if voice.playing:
			count += 1
	return count


func _input(event: InputEvent) -> void:
	if _unlocked:
		return
	# A gamepad press is no browser gesture, and a touch only counts on release, so a touch
	# press starts the ambient but the unlock is not final until a real gesture lands.
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		_start_loops()
		_unlocked = not event is InputEventScreenTouch or not event.is_pressed()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"audio_mute"):
		toggle_mute()


func _process(delta: float) -> void:
	_engine_level = lerpf(_engine_level, _speed_ratio, 1.0 - exp(-tuning.engine_response * delta))
	_apply_engine_level()


func _unlock() -> void:
	_unlocked = true
	_start_loops()


func _start_loops() -> void:
	for player: AudioStreamPlayer in [_ambient, _engine]:
		if not player.playing:
			player.play()


func _make_loop(path: String) -> AudioStreamPlayer:
	var stream: AudioStream = load(path)
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	return player


func _on_tank_speed_changed(forward_speed: float) -> void:
	_speed_ratio = clampf(absf(forward_speed) / tank.tuning.max_forward_speed, 0.0, 1.0)


func _apply_engine_level() -> void:
	_engine.pitch_scale = lerpf(tuning.engine_idle_pitch, tuning.engine_full_pitch, _engine_level)
	_engine.volume_db = lerpf(tuning.engine_idle_db, tuning.engine_full_db, _engine_level)


func _on_projectile_impacted(_position: Vector3, _normal: Vector3, _collider: Node3D) -> void:
	_play_one_shot(_explosion, tuning.explosion_db)


func _play_one_shot(stream: AudioStream, volume_db: float) -> void:
	var voice: AudioStreamPlayer = _voices[_next_voice]
	for i: int in _voices.size():
		var candidate: AudioStreamPlayer = _voices[(_next_voice + i) % _voices.size()]
		if not candidate.playing:
			voice = candidate
			break
	_next_voice = (_voices.find(voice) + 1) % _voices.size()
	voice.stream = stream
	voice.volume_db = volume_db
	voice.play()


func _register_input_actions() -> void:
	if InputMap.has_action(&"audio_mute"):
		return
	InputMap.add_action(&"audio_mute")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_M
	InputMap.action_add_event(&"audio_mute", key)
