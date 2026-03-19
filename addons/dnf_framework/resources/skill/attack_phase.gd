class_name DNFAttackPhase
extends Resource

## 攻击区间 — 一段帧区间共享一个碰撞体和受击行为

## 攻击判定开始帧
@export var start_frame: int = 0
## 攻击判定结束帧
@export var end_frame: int = 5
## 碰撞体数据（DNFHitboxData）
@export var hitbox: Resource
## 受击行为（DNFHitBehavior）
@export var hit_behavior: Resource
## 该区间内的帧事件（DNFFrameEvent）
@export var events: Array = []


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame
