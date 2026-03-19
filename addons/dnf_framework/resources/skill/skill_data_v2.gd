class_name DNFSkillDataV2
extends Resource

## 技能定义 — Phase 区间模型（核心）
## 显示层 = AnimationData，逻辑层 = phases + events + movement

enum DamageType { PHYSICAL_PERCENT, MAGICAL_PERCENT, INDEPENDENT }
enum Element { NEUTRAL, FIRE, ICE, LIGHT, DARK }
enum SuperArmorLevel { NONE, LIGHT, HEAVY, FULL }

@export_group("基本信息")
@export var skill_name: String = ""
@export var display_name: String = ""
@export var animation: Resource  # DNFAnimationData

@export_group("攻击区间（核心逻辑层）")
@export var phases: Array = []  # Array of DNFAttackPhase
@export var events: Array = []  # Array of DNFFrameEvent
@export var movement: Array = []  # Array of DNFMovementPhase

@export_group("消耗与冷却")
@export var mp_cost: int = 0
@export var hp_cost: int = 0
@export var cooldown_frames: int = 0

@export_group("伤害属性")
@export var damage_type: DamageType = DamageType.PHYSICAL_PERCENT
@export var element: Element = Element.NEUTRAL
@export var skill_coefficient: float = 1.0
@export var super_armor_level: SuperArmorLevel = SuperArmorLevel.NONE

@export_group("取消系统")
@export var cancelable: bool = false
@export var cancel_into: Array[String] = []

@export_group("使用条件")
@export var ground_only: bool = true
@export var air_usable: bool = false
@export var priority: int = 0
@export var input_conditions: Array = []  # Array of DNFInputCondition

@export_group("UI")
@export var ui: Resource  # DNFSkillUIData


func get_total_frames() -> int:
	if animation:
		return animation.get_total_frames()
	return 0


func get_phases_at_frame(frame: int) -> Array:
	var result: Array = []
	for phase in phases:
		if phase.contains_frame(frame):
			result.append(phase)
	return result


func get_movement_at_frame(frame: int) -> Array:
	var result: Array = []
	for mov in movement:
		if mov.contains_frame(frame):
			result.append(mov)
	return result


func get_events_at_frame(frame: int) -> Array:
	var result: Array = []
	for ev in events:
		if ev.frame == frame:
			result.append(ev)
	for phase in phases:
		for ev in phase.events:
			if ev.frame == frame:
				result.append(ev)
	return result


func check_input(input_dict: Dictionary) -> bool:
	if input_conditions.is_empty():
		return false
	for cond in input_conditions:
		if not cond.check_valid(input_dict):
			return false
	return true
