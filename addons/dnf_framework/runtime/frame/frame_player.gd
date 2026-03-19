class_name DNFFramePlayer
extends Node

## 帧播放器 — 只管显示，不管逻辑
## 按 AnimationData 的帧率和速率倍率逐帧推进

signal frame_changed(frame_index: int)
signal animation_finished(anim_name: String)
signal animation_started(anim_name: String)

@export var sprite: Sprite2D

var _anim: Resource  # DNFAnimationData
var _frame_index: int = 0
var _playing: bool = false
var _timer: float = 0.0


func play(anim: Resource, start_frame: int = 0) -> void:
	if anim == null or anim.frames.is_empty():
		return
	_anim = anim
	_frame_index = clampi(start_frame, 0, _anim.frames.size() - 1)
	_timer = 0.0
	_playing = true
	animation_started.emit(_anim.anim_name)
	_apply_display()
	frame_changed.emit(_frame_index)


## delta 模式：传入 _process / _physics_process 的 delta
func advance(delta: float) -> void:
	if not _playing or _anim == null:
		return
	var effective_fps: float = _anim.get_effective_fps()
	if effective_fps <= 0:
		return
	_timer += delta
	var interval: float = 1.0 / effective_fps
	while _timer >= interval:
		_timer -= interval
		_advance_one_frame()
		if not _playing:
			break


## tick 模式（兼容回滚网络同步）：每次调用推进 1/fps 秒
func tick() -> void:
	if not _playing or _anim == null:
		return
	var effective_fps: float = _anim.get_effective_fps()
	if effective_fps <= 0:
		return
	_timer += 1.0 / _anim.fps  # tick 以基础帧率为基准
	var interval: float = 1.0 / effective_fps
	while _timer >= interval:
		_timer -= interval
		_advance_one_frame()
		if not _playing:
			break


func _advance_one_frame() -> void:
	_frame_index += 1
	if _frame_index >= _anim.frames.size():
		if _anim.loop:
			_frame_index = 0
		else:
			_frame_index = _anim.frames.size() - 1
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
	if f.texture:
		sprite.texture = f.texture
		sprite.region_enabled = false
	elif _anim.atlas:
		sprite.texture = _anim.atlas
		if f.region != Rect2():
			sprite.region_enabled = true
			sprite.region_rect = f.region
	sprite.offset = f.anchor_offset


func stop() -> void:
	_playing = false


func reset() -> void:
	_frame_index = 0
	_timer = 0.0
	_playing = false


func is_playing() -> bool:
	return _playing


func get_current_frame_index() -> int:
	return _frame_index


func get_total_frames() -> int:
	if _anim:
		return _anim.frames.size()
	return 0


func get_progress() -> float:
	if _anim == null or _anim.frames.size() <= 1:
		return 0.0
	return float(_frame_index) / float(_anim.frames.size() - 1)


func get_current_anim():
	return _anim


func _save_state() -> Dictionary:
	return {
		"fi": _frame_index,
		"tm": _timer,
		"pl": _playing,
		"an": _anim.anim_name if _anim else "",
	}


func _load_state(state: Dictionary) -> void:
	_frame_index = state.get("fi", 0)
	_timer = state.get("tm", 0.0)
	_playing = state.get("pl", false)
