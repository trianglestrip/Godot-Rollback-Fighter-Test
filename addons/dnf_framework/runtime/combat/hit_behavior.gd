class_name DNFHitBehavior
extends Resource

## 受击行为定义：描述一次攻击命中后的效果

enum HitType {
	NORMAL,
	KNOCK_BACK,
	KNOCK_DOWN,
	LAUNCH,
}

enum DamageType {
	PHYSICAL_PERCENT,
	MAGICAL_PERCENT,
	INDEPENDENT,
}

enum Element {
	NEUTRAL,
	FIRE,
	ICE,
	LIGHT,
	DARK,
}

enum HitMode {
	ONCE,       ## 整个 Phase 只命中一次（默认，DNF 常见）
	PER_FRAME,  ## 每帧都判定（持续伤害型）
	INTERVAL,   ## 每 hit_interval 帧判定一次（多段技能）
}

@export_group("伤害")
@export var damage: int = 10
@export var damage_type: DamageType = DamageType.PHYSICAL_PERCENT
@export var element: Element = Element.NEUTRAL
@export var skill_coefficient: float = 1.0
@export var fixed_damage: int = 0

@export_group("命中策略")
@export var hit_mode: HitMode = HitMode.ONCE
## 多段间隔帧数（仅 INTERVAL 模式生效）
@export var hit_interval: int = 3
## 最大命中次数（0 = 无限制）
@export var max_hits: int = 1

@export_group("受击效果")
@export var hit_type: HitType = HitType.NORMAL
@export var hitstun_frames: int = 12
@export var hitstop_frames: int = 3

@export_group("击退")
@export var knockback_force: float = 6.0
@export var launch_force: float = -18.0
@export var self_knockback: float = 2.0

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
