class_name DNFMove
extends Resource

## 招式定义：一个可执行的攻击/技能

@export var move_name: String = ""
@export var input_conditions: Array[DNFInputType] = []
@export var state: int = DNFStates.State.ATTACK
@export var anim_name: String = ""
@export var duration: int = 20
@export var active_start: int = 5
@export var active_end: int = 10
@export var priority: int = 0
@export var hit_behavior: DNFHitBehavior
@export var breaks: bool = false
@export var forward_impulse: float = 2.0


func check_input(input_dict: Dictionary) -> bool:
	if input_conditions.is_empty():
		return false
	for cond in input_conditions:
		if not cond.check_valid(input_dict):
			return false
	return true
