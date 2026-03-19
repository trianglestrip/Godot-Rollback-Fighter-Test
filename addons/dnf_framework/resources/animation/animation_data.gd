class_name DNFAnimationData
extends Resource

## 帧序列动画数据 — 纯显示层
## 播放时间 = 帧数 / (fps × speed_scale)

## 动画名称（如 "idle"、"slash"）
@export var anim_name: String = ""
## 基础帧率（每秒播放几帧，所有动画共用同一基准）
@export var fps: int = 12
## 速率倍率（1.0 = 正常速度，2.0 = 两倍速，0.5 = 半速）
@export var speed_scale: float = 1.0
## 帧数据数组，按播放顺序排列（DNFFrameData）
@export var frames: Array = []
## 是否循环播放
@export var loop: bool = false
## 精灵图集纹理（使用独立纹理模式时可不设）
@export var atlas: Texture2D


func get_total_frames() -> int:
	return frames.size()


func get_frame_at_index(index: int):
	if frames.is_empty():
		return null
	if index < 0 or index >= frames.size():
		return frames[frames.size() - 1]
	return frames[index]


## 获取实际播放帧率（fps × speed_scale）
func get_effective_fps() -> float:
	return fps * speed_scale


## 获取总播放时长（秒）
func get_duration_seconds() -> float:
	if frames.is_empty() or fps <= 0 or speed_scale <= 0:
		return 0.0
	return float(frames.size()) / get_effective_fps()
