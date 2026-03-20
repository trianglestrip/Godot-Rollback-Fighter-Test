class_name DNFFighterState
extends Resource

## 单个战斗状态定义

@export var state_name: String = ""
@export var anim_name: String = ""
@export var state_length: int = -1
@export var state_loop: bool = false
@export var preserve_momentum: bool = false
@export var state_events: Array[DNFStateEvent] = []
@export var state_enter_events: Array[DNFStateEvent] = []
@export var state_exit_events: Array[DNFStateEvent] = []
