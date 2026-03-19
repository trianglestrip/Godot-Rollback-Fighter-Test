class_name DNFInputCondition
extends Resource

## 输入条件基类 — 子类实现具体检测逻辑

enum ConditionType { EQUAL_CHECK, COMMAND_MOTION, HOLD_CHECK, DOUBLE_TAP }

@export var condition_type: ConditionType = ConditionType.EQUAL_CHECK
@export var input_name: String = ""
@export var input_value: bool = true
@export var motion_sequence: Array[String] = []
@export var hold_frames: int = 10
@export var tap_window: int = 15


func check_valid(input_dict: Dictionary) -> bool:
	match condition_type:
		ConditionType.EQUAL_CHECK:
			return input_dict.get(input_name, false) == input_value
		ConditionType.HOLD_CHECK:
			return input_dict.get(input_name + "_held", 0) >= hold_frames
		_:
			return false
