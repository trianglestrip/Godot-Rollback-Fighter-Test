class_name DNFFrameEvent
extends Resource

## 单帧事件 — 在指定帧触发一次性逻辑

enum EventType {
	SPAWN_EFFECT,
	PLAY_SOUND,
	CAMERA_SHAKE,
	SPAWN_PROJECTILE,
	APPLY_BUFF,
	SUPER_ARMOR_START,
	SUPER_ARMOR_END,
	INVINCIBLE_START,
	INVINCIBLE_END,
	CANCEL_WINDOW_OPEN,
	CANCEL_WINDOW_CLOSE,
	CUSTOM_SIGNAL,
}

@export var frame: int = 0
@export var type: EventType = EventType.CUSTOM_SIGNAL
@export var data: Dictionary = {}
