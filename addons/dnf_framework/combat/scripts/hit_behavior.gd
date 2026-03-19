class_name DNFHitBehavior
extends Resource

## 受击行为定义：描述一次攻击命中后的效果

const PRELOAD_DNF_STATES = preload("res://addons/dnf_framework/state_machine/scripts/dnf_states.gd")

enum HitType {
	NORMAL,
	KNOCK_BACK,
	KNOCK_DOWN,
	LAUNCH,
}

## 伤害值
@export var damage: int = 10

## 受击类型
@export var hit_type: HitType = HitType.NORMAL

## 硬直帧数（被攻击方的僵直时间）
@export var hitstun_frames: int = 12

## 顿帧帧数（双方暂停的帧数，打击感）
@export var hitstop_frames: int = 3

## 击退力度（水平方向）
@export var knockback_force: float = 6.0

## 击飞力度（垂直方向，仅 LAUNCH 类型使用）
@export var launch_force: float = -18.0

## 攻击方自身击退（后坐力）
@export var self_knockback: float = 2.0

## 被击中后切换到的状态（DNFStates.State 枚举值）
func get_hit_state() -> int:
	match hit_type:
		HitType.NORMAL:
			return DNFStates.State.HIT_STUN
		HitType.KNOCK_BACK:
			return DNFStates.State.KNOCK_BACK
		HitType.KNOCK_DOWN:
			return DNFStates.State.KNOCK_DOWN
		HitType.LAUNCH:
			return DNFStates.State.AIR_BORNE
	return DNFStates.State.HIT_STUN
