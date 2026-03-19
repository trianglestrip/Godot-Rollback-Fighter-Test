class_name DNFFrameEvent
extends Resource

## 单帧事件 — 在指定帧触发一次性逻辑

enum EventType {
	SPAWN_EFFECT,        ## 生成特效
	PLAY_SOUND,          ## 播放音效
	CAMERA_SHAKE,        ## 镜头震动
	SPAWN_PROJECTILE,    ## 生成弹幕/投射物
	APPLY_BUFF,          ## 施加BUFF
	SUPER_ARMOR_START,   ## 开启霸体
	SUPER_ARMOR_END,     ## 关闭霸体
	INVINCIBLE_START,    ## 开启无敌
	INVINCIBLE_END,      ## 关闭无敌
	CANCEL_WINDOW_OPEN,  ## 开放取消窗口
	CANCEL_WINDOW_CLOSE, ## 关闭取消窗口
	CUSTOM_SIGNAL,       ## 自定义信号
}

## 触发帧
@export var frame: int = 0
## 事件类型
@export var type: EventType = EventType.CUSTOM_SIGNAL
## 附加数据
@export var data: Dictionary = {}
