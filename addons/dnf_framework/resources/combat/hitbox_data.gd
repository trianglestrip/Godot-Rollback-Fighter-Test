class_name DNFHitboxData
extends Resource

## 碰撞体数据（纯数据，运行时由 HitboxComponent 创建实际 Area2D）

enum HitLevel {
	MID,         ## 中段攻击（站防可挡）
	LOW,         ## 下段攻击（需蹲防）
	OVERHEAD,    ## 上段攻击（需站防）
	UNBLOCKABLE, ## 不可防御
}

## 碰撞体尺寸（宽, 高）
@export var shape_size: Vector2 = Vector2(40, 60)
## 碰撞体偏移（相对角色中心，朝右时）
@export var offset: Vector2 = Vector2(30, 0)
## 攻击判定高度
@export var hit_level: HitLevel = HitLevel.MID
