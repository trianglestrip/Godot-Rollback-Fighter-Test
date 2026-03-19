class_name DNFFrameData
extends Resource

## 纯显示帧数据 — 不含任何逻辑（hitbox/event/movement 在 SkillData 层）

## 在精灵图集中的裁剪区域 (x, y, 宽, 高)
@export var region: Rect2 = Rect2()
## 该帧持续的逻辑帧数（1=最短）
@export var duration: int = 1
## 精灵锚点偏移（用于对齐脚底等）
@export var anchor_offset: Vector2 = Vector2.ZERO
## 独立纹理（当不使用 atlas 图集时，每帧可指定独立的 Texture2D）
@export var texture: Texture2D
