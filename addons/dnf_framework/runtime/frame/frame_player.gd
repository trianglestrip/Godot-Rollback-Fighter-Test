class_name DNFFramePlayer
extends Node

## 帧播放器 — 只管显示，不管逻辑
## 逐帧推进 AnimationData，更新 Sprite 的 region_rect

signal frame_changed(frame_index: int)
signal animation_finished(anim_name: String)
signal animation_started(anim_name: String)

@export var sprite: Sprite2D

var _anim: Resource  # DNFAnimationData
var _frame_index: int = 0
var _frame_timer: int = 0
var _playing: bool = false
var _total_logical_frames: int = 0


func play(anim: Resource, start_frame: int = 0) -> void:
	if anim == null or anim.frames.is_empty():
		return
	_anim = anim
	_frame_index = clampi(start_frame, 0, maxi(_anim.get_total_frames() - 1, 0))
	_frame_timer = 0
	_total_logical_frames = _anim.get_total_frames()
	_playing = true
	animation_started.emit(_anim.anim_name)
	_apply_display()
	frame_changed.emit(_frame_index)


func tick() -> void:
	if not _playing or _anim == null:
		return
	_frame_timer += 1
	var f = _anim.get_frame_at_index(_frame_index)
	if f == null:
		return
	if _frame_timer >= f.duration:
		_frame_timer = 0
		_frame_index += 1
		if _frame_index >= _total_logical_frames:
			if _anim.loop:
				_frame_index = 0
			else:
				_frame_index = _total_logical_frames - 1
				_playing = false
				animation_finished.emit(_anim.anim_name)
				return
		_apply_display()
		frame_changed.emit(_frame_index)


func _apply_display() -> void:
	if sprite == null or _anim == null:
		return
	var f = _anim.get_frame_at_index(_frame_index)
	if f == null:
		return
	if _anim.atlas:
		sprite.texture = _anim.atlas
	if f.region != Rect2():
		sprite.region_enabled = true
		sprite.region_rect = f.region
	sprite.offset = f.anchor_offset


func stop() -> void:
	_playing = false


func reset() -> void:
	_frame_index = 0
	_frame_timer = 0
	_playing = false


func is_playing() -> bool:
	return _playing


func get_current_frame_index() -> int:
	return _frame_index


func get_total_frames() -> int:
	return _total_logical_frames


func get_progress() -> float:
	if _total_logical_frames <= 1:
		return 0.0
	return float(_frame_index) / float(_total_logical_frames - 1)


func get_current_anim():
	return _anim


func _save_state() -> Dictionary:
	return {
		"fi": _frame_index,
		"ft": _frame_timer,
		"pl": _playing,
		"tl": _total_logical_frames,
		"an": _anim.anim_name if _anim else "",
	}


func _load_state(state: Dictionary) -> void:
	_frame_index = state.get("fi", 0)
	_frame_timer = state.get("ft", 0)
	_playing = state.get("pl", false)
	_total_logical_frames = state.get("tl", 0)
