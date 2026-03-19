class_name DNFSkillData
extends Resource

## 技能数据定义：Skill = Animation + Events + Data
## 所有技能必须是数据驱动的，避免硬编码技能逻辑

const PRELOAD_SKILL_EVENT = preload("res://addons/dnf_framework/skill_system/scripts/skill_event.gd")
const PRELOAD_DNF_STATES = preload("res://addons/dnf_framework/state_machine/scripts/dnf_states.gd")

## 技能唯一标识名
@export var skill_name: String = ""

## 技能显示名称
@export var display_name: String = ""

## 动画名称（对应 SpriteFrames 或 FrameAnimationPlayer）
@export var anim_name: String = ""

## 技能总帧数
@export var total_frames: int = 30

## 技能冷却帧数（0 = 无冷却）
@export var cooldown_frames: int = 0

## 技能优先级（高优先级可打断低优先级）
@export var priority: int = 0

## 是否可以被取消
@export var cancelable: bool = false

## 取消窗口帧范围（仅在此范围内可取消）
@export var cancel_window: Vector2i = Vector2i(-1, -1)

## 是否需要在地面上执行
@export var ground_only: bool = true

## 是否可以在空中执行
@export var air_usable: bool = false

## 执行技能时进入的状态（DNFStates.State 枚举值）
@export var enter_state: int = DNFStates.State.ATTACK

## 帧事件列表（每帧检查并触发）
@export var frame_events: Array[DNFSkillEvent] = []

## 技能开始时执行的事件
@export var start_events: Array[DNFSkillEvent] = []

## 技能结束时执行的事件
@export var end_events: Array[DNFSkillEvent] = []


func is_in_cancel_window(frame: int) -> bool:
	if cancel_window.x < 0:
		return cancelable
	var in_window := frame >= cancel_window.x
	in_window = in_window and (cancel_window.y < 0 or frame < cancel_window.y)
	return cancelable and in_window
