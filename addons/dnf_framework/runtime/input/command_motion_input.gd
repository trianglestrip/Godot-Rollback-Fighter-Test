class_name DNFCommandMotionInput
extends "res://addons/dnf_framework/runtime/input/input_type.gd"

## 指令输入检测：从 input_history 中回溯匹配序列（如 QCF = 下 -> 下前 -> 前）

@export var input_sequence_right: Array[String] = []
@export var input_sequence_left: Array[String] = []
@export var buffer_window: int = 15
@export var required_button: String = ""


func _check(input_dict: Dictionary) -> bool:
	if required_button != "" and not input_dict.get(required_button, false):
		return false

	var history: Array = input_dict.get("_input_history", [])
	if history.is_empty():
		return false

	var facing_right: bool = input_dict.get("_facing_right", true)
	var sequence: Array[String] = input_sequence_right if facing_right else input_sequence_left

	if sequence.is_empty():
		return false

	return _match_sequence(history, sequence)


func _match_sequence(history: Array, sequence: Array[String]) -> bool:
	var seq_idx := sequence.size() - 1
	var frames_checked := 0

	for i in range(history.size() - 1, -1, -1):
		if frames_checked >= buffer_window:
			break
		frames_checked += 1

		var entry: Dictionary = history[i]
		var dir_str: String = entry.get("direction", "")

		if dir_str == sequence[seq_idx]:
			seq_idx -= 1
			if seq_idx < 0:
				return true
		elif dir_str != "" and dir_str != sequence[seq_idx]:
			if seq_idx < sequence.size() - 1:
				return false

	return false
