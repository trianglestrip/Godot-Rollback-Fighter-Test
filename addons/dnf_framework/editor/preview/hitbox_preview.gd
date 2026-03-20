@tool
extends Control

## 碰撞体预览 — 在精灵预览上叠加 hitbox/hurtbox 矩形
## 根据当前帧所在 phase 绘制 hitbox（红框）和 hurtbox（蓝框）

## 技能数据（DNFSkillData）
var skill_data: Resource:
	set(v):
		skill_data = v
		queue_redraw()
## 当前逻辑帧
var current_frame: int = 0:
	set(v):
		current_frame = v
		queue_redraw()
## 是否显示碰撞体
var show_hitboxes: bool = true:
	set(v):
		show_hitboxes = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)


func _draw() -> void:
	var width := size.x
	var height := size.y

	if not show_hitboxes or not skill_data:
		return

	var phases: Array = skill_data.phases if "phases" in skill_data else []
	var phases_at_frame: Array = []
	for p in phases:
		if p and p.has_method("contains_frame") and p.contains_frame(current_frame):
			phases_at_frame.append(p)

	var hurtbox_size := Vector2(40, 60)
	var center := Vector2(width, height) * 0.5
	var hurtbox_rect := Rect2(center - hurtbox_size * 0.5, hurtbox_size)
	draw_rect(hurtbox_rect, Color(0, 0, 1, 0.2))
	draw_rect(hurtbox_rect, Color(0.3, 0.5, 1), false)

	for phase in phases_at_frame:
		var hitbox_data = phase.hitbox if "hitbox" in phase else null
		if not hitbox_data:
			continue
		var shape_size: Vector2 = hitbox_data.shape_size
		var offset: Vector2 = hitbox_data.offset
		var hitbox_rect := Rect2(center + offset - shape_size * 0.5, shape_size)
		draw_rect(hitbox_rect, Color(1, 0, 0, 0.3))
		draw_rect(hitbox_rect, Color(1, 0.2, 0.2), false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
