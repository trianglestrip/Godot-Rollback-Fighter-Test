class_name DNFSkillHitboxEvent
extends "res://addons/dnf_framework/skill_system/scripts/skill_event.gd"

## 技能帧事件：在帧范围内激活/关闭 Hitbox，支持多段攻击

const PRELOAD_HIT_BEHAVIOR = preload("res://addons/dnf_framework/combat/scripts/hit_behavior.gd")
const PRELOAD_HITBOX = preload("res://addons/dnf_framework/combat/scripts/dnf_hitbox.gd")

## 目标 Hitbox 的节点路径
@export var hitbox_path: NodePath

## 受击行为（覆盖 Hitbox 自身的 hit_behavior）
@export var hit_behavior: DNFHitBehavior


func activate(fighter: Node, _frame: int) -> void:
	var hitbox := fighter.get_node_or_null(hitbox_path) as DNFHitbox
	if hitbox == null:
		return
	if hit_behavior:
		hitbox.hit_behavior = hit_behavior
	hitbox.activate()


func deactivate(fighter: Node) -> void:
	var hitbox := fighter.get_node_or_null(hitbox_path) as DNFHitbox
	if hitbox == null:
		return
	hitbox.deactivate()
