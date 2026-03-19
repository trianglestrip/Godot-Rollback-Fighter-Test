class_name DNFInputCondition
extends Resource

## 输入条件 — 定义技能的触发方式

enum ConditionType {
	EQUAL_CHECK,    ## 键值匹配（如 punch=true）
	COMMAND_MOTION, ## 指令输入（如 ↓↘→）
	HOLD_CHECK,     ## 长按检测
	DOUBLE_TAP,     ## 双击检测
}

## 条件类型
@export var condition_type: ConditionType = ConditionType.EQUAL_CHECK
## 输入键名（如 "punch"、"skill_1"）
@export var input_name: String = ""
## 期望值（EQUAL_CHECK 类型使用）
@export var input_value: bool = true
## 指令序列（COMMAND_MOTION 类型使用，如 ["down","down_right","right"]）
@export var motion_sequence: Array[String] = []
## 按住帧数（HOLD_CHECK 类型使用）
@export var hold_frames: int = 10
## 双击窗口帧数（DOUBLE_TAP 类型使用）
@export var tap_window: int = 15


func check_valid(input_dict: Dictionary) -> bool:
	match condition_type:
		ConditionType.EQUAL_CHECK:
			return input_dict.get(input_name, false) == input_value
		ConditionType.HOLD_CHECK:
			return input_dict.get(input_name + "_held", 0) >= hold_frames
		_:
			return false
