class_name DNFFighterState
extends Resource

## 单个战斗状态定义

const PRELOAD_STATE_EVENT = preload("res://addons/dnf_framework/state_machine/scripts/state_event.gd")

## 状态名称（用于调试/显示）
@export var state_name: String = ""

## 动画名称（对应 SpriteFrames 中的动画）
@export var anim_name: String = ""

## 状态持续帧数（-1 = 无限循环，由外部切换）
@export var state_length: int = -1

## 是否循环（到 state_length 后自动重置 tick）
@export var state_loop: bool = false

## 是否保持进入时的动量
@export var preserve_momentum: bool = false

## 状态内事件列表
@export var state_events: Array[DNFStateEvent] = []

## 进入时执行的事件
@export var state_enter_events: Array[DNFStateEvent] = []

## 退出时执行的事件
@export var state_exit_events: Array[DNFStateEvent] = []
