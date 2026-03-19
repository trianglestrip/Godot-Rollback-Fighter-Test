class_name DNFHitboxData
extends Resource

## 碰撞体数据（纯数据，运行时由 HitboxComponent 创建实际 Area2D）

enum HitLevel { MID, LOW, OVERHEAD, UNBLOCKABLE }

@export var shape_size: Vector2 = Vector2(40, 60)
@export var offset: Vector2 = Vector2(30, 0)
@export var hit_level: HitLevel = HitLevel.MID
