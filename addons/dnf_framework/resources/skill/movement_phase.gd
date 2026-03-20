class_name DNFMovementPhase
extends Resource

## 位移区间 — 一段帧区间内持续施加位移
## 支持恒定速度和 Curve 曲线驱动两种模式

enum MotionType {
	CONSTANT,  ## 匀速位移
	CURVE,     ## 曲线驱动（突进 / 减速 / 变速）
}

## 位移开始帧
@export var start_frame: int = 0
## 位移结束帧
@export var end_frame: int = 5

@export_group("位移模式")
## 运动类型
@export var motion_type: MotionType = MotionType.CONSTANT
## 恒定位移速度（像素/帧），CONSTANT 模式使用
@export var velocity: Vector2 = Vector2.ZERO
## 位移曲线（X 轴 0~1 表示区间进度，Y 轴表示速度倍率 0~1），CURVE 模式使用
@export var curve: Curve
## 总位移距离（像素），CURVE 模式下配合 curve 使用
@export var distance: float = 100.0
## 曲线方向角度（弧度，0=向右），CURVE 模式下使用
@export var curve_direction: Vector2 = Vector2(1, 0)
## 是否根据角色朝向自动翻转X轴
@export var relative_to_facing: bool = true


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame


func get_duration() -> int:
	return end_frame - start_frame + 1


func get_velocity_at_frame(frame: int) -> Vector2:
	if not contains_frame(frame):
		return Vector2.ZERO

	match motion_type:
		MotionType.CONSTANT:
			return velocity
		MotionType.CURVE:
			if curve == null:
				return Vector2.ZERO
			var duration := get_duration()
			if duration <= 0:
				return Vector2.ZERO
			var progress := float(frame - start_frame) / float(duration)
			progress = clampf(progress, 0.0, 1.0)
			var multiplier := curve.sample(progress)
			var speed_per_frame := distance / float(duration)
			return curve_direction * speed_per_frame * multiplier

	return Vector2.ZERO
