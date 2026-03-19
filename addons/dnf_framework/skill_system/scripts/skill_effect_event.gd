class_name DNFSkillEffectEvent
extends "res://addons/dnf_framework/skill_system/scripts/skill_event.gd"

## 技能帧事件：在指定帧触发视觉/音效/信号等效果

enum EffectType {
	SIGNAL,
	CAMERA_SHAKE,
	FREEZE_FRAME,
}

## 效果类型
@export var effect_type: EffectType = EffectType.SIGNAL

## 自定义信号名称（EffectType.SIGNAL 时使用）
@export var signal_name: String = ""

## 效果强度参数（相机震动强度 / 冻结帧数等）
@export var intensity: float = 1.0

## 额外数据（传递给信号的字典）
@export var extra_data: Dictionary = {}


func activate(fighter: Node, _frame: int) -> void:
	match effect_type:
		EffectType.SIGNAL:
			if signal_name != "" and fighter.has_signal(signal_name):
				fighter.emit_signal(signal_name, extra_data)
		EffectType.CAMERA_SHAKE:
			if fighter.has_method("apply_camera_shake"):
				fighter.apply_camera_shake(intensity)
		EffectType.FREEZE_FRAME:
			if fighter.has_method("apply_freeze_frame"):
				fighter.apply_freeze_frame(int(intensity))
