class_name DNFMove
extends Resource

## 招式定义：一个可执行的攻击/技能

const PRELOAD_INPUT_TYPE = preload("res://addons/dnf_framework/move_system/scripts/input_type.gd")
const PRELOAD_DNF_STATES = preload("res://addons/dnf_framework/state_machine/scripts/dnf_states.gd")
const PRELOAD_HIT_BEHAVIOR = preload("res://addons/dnf_framework/combat/scripts/hit_behavior.gd")

## 招式名称
@export var move_name: String = ""

## 输入条件（全部满足时招式可以执行）
@export var input_conditions: Array[DNFInputType] = []

## 执行招式后进入的状态
@export var state: int = DNFStates.State.ATTACK

## 动画名称
@export var anim_name: String = ""

## 招式持续帧数
@export var duration: int = 20

## 攻击激活帧范围
@export var active_start: int = 5
@export var active_end: int = 10

## 招式优先级（高优先级的先检查）
@export var priority: int = 0

## 受击行为
@export var hit_behavior: DNFHitBehavior

## 是否中断后续招式检查（高优先级阻断用）
@export var breaks: bool = false

## 前进力度
@export var forward_impulse: float = 2.0


func check_input(input_dict: Dictionary) -> bool:
	if input_conditions.is_empty():
		return false
	for cond in input_conditions:
		if not cond.check_valid(input_dict):
			return false
	return true
