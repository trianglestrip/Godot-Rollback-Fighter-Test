class_name DNFEffectLayer
extends Resource

## 特效层 — 表现 + 轻量碰撞（不含复杂逻辑）
## 复杂逻辑（事件、霸体等）统一由 SkillData.events 调度
## 特效层只负责：播动画、飞行位移、可选简单碰撞

@export_group("基本信息")
## 特效层名称（用于编辑器识别）
@export var layer_name: String = ""
## 关联的动画名（对应 SpriteFrames 中的动画名）
@export var animation_name: String = ""
## 在主动画第几帧生成此特效（相对主动画帧数）
@export var spawn_frame: int = 0
## 生成位置偏移（相对角色原点）
@export var offset: Vector2 = Vector2.ZERO
## 是否根据角色朝向翻转偏移 X
@export var relative_to_facing: bool = true
## 生成后是否跟随角色移动（false = 生成后独立飞行）
@export var follow_character: bool = false

@export_group("飞行位移")
## 特效自身的位移列表（DNFMovementPhase），帧数相对特效自身 spawn 时刻
@export var movement: Array = []

@export_group("碰撞")
## 碰撞体数据（DNFHitboxData），null = 纯表现无碰撞
@export var hitbox: Resource
## 受击行为（DNFHitBehavior）
@export var hit_behavior: Resource
## 碰撞判定开始帧（相对特效自身 spawn 时刻）
@export var hitbox_start_frame: int = 0
## 碰撞判定结束帧（相对特效自身 spawn 时刻）
@export var hitbox_end_frame: int = 0


func has_hitbox() -> bool:
	return hitbox != null


func hitbox_active_at_frame(local_frame: int) -> bool:
	return hitbox != null and local_frame >= hitbox_start_frame and local_frame <= hitbox_end_frame


func get_movement_at_frame(local_frame: int) -> Array:
	var result: Array = []
	for mov in movement:
		if mov.contains_frame(local_frame):
			result.append(mov)
	return result
