class_name DNFSkillMovementEvent
extends "res://addons/dnf_framework/skill_system/scripts/skill_event.gd"

## 技能帧事件：在帧范围内施加移动（冲刺/位移技能）

## 水平力度（正值 = 面朝方向前进，负值 = 后退）
@export var horizontal_impulse: float = 0.0

## 垂直力度（负值 = 向上）
@export var vertical_impulse: float = 0.0

## 是否相对于角色朝向（true = 自动翻转水平方向）
@export var relative_to_facing: bool = true

## 是否每帧持续施加（false = 仅第一帧施加一次）
@export var continuous: bool = false

var _applied: bool = false


func activate(fighter: Node, _frame: int) -> void:
	if not continuous and _applied:
		return

	if not fighter is CharacterBody2D:
		return

	var body := fighter as CharacterBody2D
	var dir_sign := 1.0
	if relative_to_facing and fighter.has_method("_update_facing"):
		dir_sign = 1.0 if fighter.facing_right else -1.0

	body.velocity.x += horizontal_impulse * dir_sign
	body.velocity.y += vertical_impulse
	_applied = true


func deactivate(_fighter: Node) -> void:
	_applied = false


func reset() -> void:
	super.reset()
	_applied = false
