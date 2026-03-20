class_name DNFInputEqualCheck
extends "res://addons/dnf_framework/runtime/input/input_type.gd"

## 检查输入字典中某个键是否等于预期值

@export var input_name: String = ""
@export var input_value: Variant = true


func _check(input_dict: Dictionary) -> bool:
	if not input_dict.has(input_name):
		return false
	return input_dict[input_name] == input_value
