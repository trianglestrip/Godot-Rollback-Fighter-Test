class_name DNFSkillDataV2
extends Resource

## 技能定义 — Phase 区间模型（核心）
## 显示层 = AnimationData，逻辑层 = phases + events + movement

enum DamageType { PHYSICAL_PERCENT, MAGICAL_PERCENT, INDEPENDENT }
enum Element { NEUTRAL, FIRE, ICE, LIGHT, DARK }
enum SuperArmorLevel { NONE, LIGHT, HEAVY, FULL }

@export_group("基本信息")
## 技能内部名称（唯一标识）
@export var skill_name: String = ""
## 技能显示名称
@export var display_name: String = ""
## 关联的帧动画数据（DNFAnimationData）
@export var animation: Resource

@export_group("攻击区间")
## 攻击判定区间列表（DNFAttackPhase）
@export var phases: Array = []
## 帧事件列表（DNFFrameEvent）
@export var events: Array = []
## 位移区间列表（DNFMovementPhase）
@export var movement: Array = []

@export_group("消耗与冷却")
## MP消耗量
@export var mp_cost: int = 0
## HP消耗量
@export var hp_cost: int = 0
## 冷却帧数（0=无冷却，60帧≈1秒）
@export var cooldown_frames: int = 0

@export_group("伤害属性")
## 伤害类型（百分比物攻/百分比魔攻/独立）
@export var damage_type: DamageType = DamageType.PHYSICAL_PERCENT
## 技能属性（无/火/冰/光/暗）
@export var element: Element = Element.NEUTRAL
## 技能系数（倍率，1.0=100%）
@export var skill_coefficient: float = 1.0
## 霸体等级（无/轻霸体/重霸体/完全霸体）
@export var super_armor_level: SuperArmorLevel = SuperArmorLevel.NONE

@export_group("取消系统")
## 是否可被取消到其他技能
@export var cancelable: bool = false
## 可取消到的技能名列表
@export var cancel_into: Array[String] = []

@export_group("使用条件")
## 仅地面可用
@export var ground_only: bool = true
## 空中可用
@export var air_usable: bool = false
## 优先级（数值越大越优先）
@export var priority: int = 0
## 输入条件列表（DNFInputCondition）
@export var input_conditions: Array = []

@export_group("技能UI")
## 技能UI显示数据（DNFSkillUIData）
@export var ui: Resource


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
