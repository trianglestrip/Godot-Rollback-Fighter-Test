class_name FrameCharacterBody2D
extends CharacterBody2D

## 基于帧的 2D 角色物理体
## velocity 直接作为每帧位移量（不乘 delta），确保确定性

signal grounded()
signal airborne()
signal landed()

@export var gravity: float = 30.0
@export var max_fall_speed: float = 900.0

var _on_floor_last_frame: bool = false
var _frame_count: int = 0


func _physics_process(_delta: float) -> void:
	process_frame()


func process_frame() -> void:
	_frame_count += 1
	_on_floor_last_frame = is_on_floor()

	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity, max_fall_speed)

	move_and_slide()

	if is_on_floor() and not _on_floor_last_frame:
		landed.emit()
	if is_on_floor() and not _on_floor_last_frame:
		grounded.emit()
	if not is_on_floor() and _on_floor_last_frame:
		airborne.emit()


func get_frame_count() -> int:
	return _frame_count


func apply_impulse(impulse: Vector2) -> void:
	velocity += impulse


func _save_state() -> Dictionary:
	return {
		"pos_x": position.x,
		"pos_y": position.y,
		"vel_x": velocity.x,
		"vel_y": velocity.y,
		"frame": _frame_count,
	}


func _load_state(state: Dictionary) -> void:
	position.x = state.get("pos_x", 0.0)
	position.y = state.get("pos_y", 0.0)
	velocity.x = state.get("vel_x", 0.0)
	velocity.y = state.get("vel_y", 0.0)
	_frame_count = state.get("frame", 0)
