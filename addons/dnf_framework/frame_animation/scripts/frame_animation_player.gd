class_name FrameAnimationPlayer
extends Node

## 基于帧计数的动画播放器，每个物理帧推进一帧，确保确定性

signal animation_finished(animation_name: String)
signal animation_frame(frame_index: int, animation_name: String)
signal animation_event(event_name: String, animation_name: String, frame_index: int)
signal animation_started(animation_name: String)

@export var sprite_frames: SpriteFrames
@export var default_animation: String = "idle"
@export var autostart: bool = false
@export var loop: bool = false

var _current_animation: String = ""
var _current_frame: int = 0
var _total_frames: int = 0
var _is_playing: bool = false
var _is_paused: bool = false
var _events: Dictionary = {}


func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint():
		return
	if autostart and default_animation != "":
		play(default_animation)


func _physics_process(_delta: float) -> void:
	if not _is_playing or _is_paused or _current_animation == "":
		return
	_advance_frame()


func _advance_frame() -> void:
	var old_frame := _current_frame
	_current_frame += 1

	if _current_frame >= _total_frames:
		if loop:
			_current_frame %= _total_frames
		else:
			_current_frame = _total_frames - 1
			_is_playing = false
			animation_finished.emit(_current_animation)
			return

	if _current_frame != old_frame:
		animation_frame.emit(_current_frame, _current_animation)
		_fire_events_for_frame(_current_frame)


func _fire_events_for_frame(frame: int) -> void:
	if not _events.has(_current_animation):
		return
	var frame_events: Array = _events[_current_animation].get(frame, [])
	for ev in frame_events:
		animation_event.emit(ev, _current_animation, frame)


func play(animation_name: String, start_frame: int = 0, restart: bool = false) -> void:
	if sprite_frames == null:
		push_error("FrameAnimationPlayer: sprite_frames is null")
		return
	if not sprite_frames.has_animation(animation_name):
		push_error("FrameAnimationPlayer: animation '" + animation_name + "' not found")
		return

	if _current_animation == animation_name and _is_playing and not restart:
		return

	_total_frames = sprite_frames.get_frame_count(animation_name)
	_current_animation = animation_name
	_current_frame = clampi(start_frame, 0, maxi(_total_frames - 1, 0))
	_is_playing = true
	_is_paused = false

	animation_started.emit(animation_name)
	animation_frame.emit(_current_frame, animation_name)
	_fire_events_for_frame(_current_frame)


func pause() -> void:
	_is_paused = true


func resume() -> void:
	_is_paused = false


func stop() -> void:
	_is_playing = false
	_is_paused = false


func reset() -> void:
	stop()
	_current_frame = 0
	if default_animation != "":
		play(default_animation)


func get_current_animation() -> String:
	return _current_animation


func get_current_frame() -> int:
	return _current_frame


func get_total_frames() -> int:
	return _total_frames


func is_playing() -> bool:
	return _is_playing


func is_paused() -> bool:
	return _is_paused


func seek_frame(frame_index: int) -> void:
	if _current_animation == "":
		return
	_current_frame = clampi(frame_index, 0, maxi(_total_frames - 1, 0))
	animation_frame.emit(_current_frame, _current_animation)
	_fire_events_for_frame(_current_frame)


func get_progress() -> float:
	if _total_frames <= 1:
		return 0.0
	return float(_current_frame) / float(_total_frames - 1)


func set_progress(progress: float) -> void:
	var idx := int(clampf(progress, 0.0, 1.0) * float(maxi(_total_frames - 1, 0)))
	seek_frame(idx)


## 手动推进一帧（外部驱动时使用，如回滚网络的 _network_process）
func advance() -> void:
	if not _is_playing or _is_paused or _current_animation == "":
		return
	_advance_frame()


func add_animation_event(animation_name: String, frame_index: int, event_name: String) -> void:
	if not _events.has(animation_name):
		_events[animation_name] = {}
	if not _events[animation_name].has(frame_index):
		_events[animation_name][frame_index] = []
	if event_name not in _events[animation_name][frame_index]:
		_events[animation_name][frame_index].append(event_name)


func remove_animation_event(animation_name: String, frame_index: int, event_name: String = "") -> void:
	if not _events.has(animation_name) or not _events[animation_name].has(frame_index):
		return
	if event_name == "":
		_events[animation_name].erase(frame_index)
	else:
		var evts: Array = _events[animation_name][frame_index]
		evts.erase(event_name)
		if evts.is_empty():
			_events[animation_name].erase(frame_index)
	if _events[animation_name].is_empty():
		_events.erase(animation_name)


func _save_state() -> Dictionary:
	return {
		"anim": _current_animation,
		"frame": _current_frame,
		"total": _total_frames,
		"playing": _is_playing,
		"paused": _is_paused,
	}


func _load_state(state: Dictionary) -> void:
	_current_animation = state.get("anim", "")
	_current_frame = state.get("frame", 0)
	_total_frames = state.get("total", 0)
	_is_playing = state.get("playing", false)
	_is_paused = state.get("paused", false)
