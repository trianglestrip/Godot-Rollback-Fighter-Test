@tool
class_name DNFAnimatedSprite2D
extends AnimatedSprite2D

## 帧动画精灵 — 继承 AnimatedSprite2D，增加回滚兼容的 tick() 驱动
##
## 完全使用 Godot 原生 SpriteFrames 资源（在编辑器中自带完整 Inspector）
## 额外提供：
##   - tick()：每逻辑帧推进 1/fps 秒，用于回滚网络同步
##   - _save_state / _load_state：回滚存档恢复
##
## 用法：
##   1. 场景中添加 DNFAnimatedSprite2D
##   2. Inspector 中设置 sprite_frames（原生 SpriteFrames）
##   3. 选择动画名、设置 autoplay
##   4. 运行时用 tick() 驱动（回滚模式）或 play() 驱动（标准模式）

signal dnf_frame_changed(frame_idx: int)

var _tick_timer: float = 0.0
var _tick_playing: bool = false
var _tick_forward: bool = true
var _tick_anim: String = ""


func tick() -> void:
	if sprite_frames == null or _tick_anim.is_empty():
		return
	if not _tick_playing:
		return
	var fps_val: float = sprite_frames.get_animation_speed(_tick_anim) * speed_scale
	if fps_val <= 0:
		return
	_tick_timer += 1.0 / fps_val
	var interval: float = 1.0 / fps_val
	while _tick_timer >= interval:
		_tick_timer -= interval
		_tick_advance_one()
		if not _tick_playing:
			break


func _tick_advance_one() -> void:
	var total: int = sprite_frames.get_frame_count(_tick_anim)
	if total <= 0:
		return
	var next: int
	if _tick_forward:
		next = frame + 1
		if next >= total:
			if sprite_frames.get_animation_loop(_tick_anim):
				frame = 0
				animation_looped.emit()
			else:
				frame = total - 1
				_tick_playing = false
				animation_finished.emit()
				return
		else:
			frame = next
	else:
		next = frame - 1
		if next < 0:
			if sprite_frames.get_animation_loop(_tick_anim):
				frame = total - 1
				animation_looped.emit()
			else:
				frame = 0
				_tick_playing = false
				animation_finished.emit()
				return
		else:
			frame = next
	dnf_frame_changed.emit(frame)


func tick_play(anim_name: String = "", from_frame: int = 0) -> void:
	if sprite_frames == null:
		return
	if anim_name.is_empty():
		anim_name = animation
	if anim_name.is_empty() or not sprite_frames.has_animation(anim_name):
		return
	_tick_forward = true
	_tick_anim = anim_name
	animation = anim_name
	frame = from_frame
	_tick_timer = 0.0
	_tick_playing = true


func tick_play_backwards(anim_name: String = "") -> void:
	if sprite_frames == null:
		return
	if anim_name.is_empty():
		anim_name = animation
	if anim_name.is_empty() or not sprite_frames.has_animation(anim_name):
		return
	_tick_forward = false
	_tick_anim = anim_name
	animation = anim_name
	var total: int = sprite_frames.get_frame_count(anim_name)
	if frame == 0 and total > 0:
		frame = total - 1
	_tick_timer = 0.0
	_tick_playing = true


func tick_stop() -> void:
	_tick_playing = false
	_tick_timer = 0.0


func tick_pause() -> void:
	_tick_playing = false


func is_tick_playing() -> bool:
	return _tick_playing


func get_current_frame() -> int:
	return frame


## ─── 回滚 save/load ───

func _save_state() -> Dictionary:
	return {
		"fi": frame,
		"tm": _tick_timer,
		"pl": _tick_playing,
		"an": _tick_anim,
		"fw": _tick_forward,
	}


func _load_state(state: Dictionary) -> void:
	_tick_forward = state.get("fw", true)
	_tick_anim = state.get("an", "")
	if not _tick_anim.is_empty():
		animation = _tick_anim
	frame = state.get("fi", 0)
	_tick_timer = state.get("tm", 0.0)
	_tick_playing = state.get("pl", false)
