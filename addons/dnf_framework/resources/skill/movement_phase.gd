class_name DNFMovementPhase
extends Resource

## 位移区间 — 一段帧区间内持续施加位移

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var velocity: Vector2 = Vector2.ZERO
@export var relative_to_facing: bool = true


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame
