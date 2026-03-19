class_name DNFAnimationData
extends Resource

## 帧序列动画数据 — 纯显示层

## 动画名称（如 "idle"、"slash"）
@export var anim_name: String = ""
## 帧率（用于预览）
@export var fps: int = 12
## 帧数据数组，按播放顺序排列（DNFFrameData）
@export var frames: Array = []
## 是否循环播放
@export var loop: bool = false
## 精灵图集纹理
@export var atlas: Texture2D


func get_total_frames() -> int:
	var total := 0
	for f in frames:
		total += f.duration
	return total


func get_frame_at_index(logical_frame: int):
	if frames.is_empty():
		return null
	var accumulated := 0
	for f in frames:
		accumulated += f.duration
		if logical_frame < accumulated:
			return f
	return frames[frames.size() - 1]
