class_name DNFAnimationData
extends Resource

## 帧序列动画数据 — 纯显示层

@export var anim_name: String = ""
@export var fps: int = 12
@export var frames: Array = []  # Array of DNFFrameData
@export var loop: bool = false
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
