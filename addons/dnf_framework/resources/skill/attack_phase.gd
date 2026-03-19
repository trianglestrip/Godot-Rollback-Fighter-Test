class_name DNFAttackPhase
extends Resource

## 攻击区间 — 一段帧区间共享一个 hitbox 和受击行为

@export var start_frame: int = 0
@export var end_frame: int = 5
@export var hitbox: Resource  # DNFHitboxData
@export var hit_behavior: Resource  # DNFHitBehavior
@export var events: Array = []  # Array of DNFFrameEvent


func contains_frame(frame: int) -> bool:
	return frame >= start_frame and frame <= end_frame
