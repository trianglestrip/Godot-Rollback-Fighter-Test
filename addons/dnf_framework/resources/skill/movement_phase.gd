class_name DNFMovementPhase
extends Resource

## 位移区间 — 一段帧区间内持续施加位移

## 位移开始帧
@export var start_frame: int = 0
## 位移结束帧
@export var end_frame: int = 5
## 位移速度（像素/帧）
@export var velocity: Vector2 = Vector2.ZERO
## 是否根据角色朝向自动翻转X轴
@export var relative_to_facing: bool = true


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame
