class_name DNFInputType
extends Resource

## 输入条件基类：检查当前输入是否满足条件

@export var auto_valid: bool = false
@export var auto_reject: bool = false


func check_valid(input_dict: Dictionary) -> bool:
	if auto_reject:
		return false
	if auto_valid:
		return true
	return _check(input_dict)


func _check(_input_dict: Dictionary) -> bool:
	return false
