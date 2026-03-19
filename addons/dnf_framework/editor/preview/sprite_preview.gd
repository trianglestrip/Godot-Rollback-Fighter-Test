@tool
extends Control

## 精灵预览 — 显示当前帧的精灵图集区域
## 从 AnimationData 读取帧数据，绘制 atlas 的 region 区域

## 动画数据（DNFAnimationData）
var animation_data: Resource:
	set(v):
		animation_data = v
		queue_redraw()
## 当前逻辑帧
var current_frame: int = 0:
	set(v):
		current_frame = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)


func _draw() -> void:
	var width := size.x
	var height := size.y

	draw_rect(Rect2(0, 0, width, height), Color(0.15, 0.15, 0.15))

	if not animation_data:
		return

	var atlas: Texture2D = animation_data.atlas if "atlas" in animation_data else null
	if not atlas:
		return

	var frame_data = _get_frame_at_logical(current_frame)
	if not frame_data:
		return

	var region: Rect2 = frame_data.region
	if region.size.x <= 0 or region.size.y <= 0:
		return

	var src_size := region.size
	var scale_factor := minf((width - 4) / src_size.x, (height - 4) / src_size.y)
	var draw_size := src_size * scale_factor
	var draw_pos := (Vector2(width, height) - draw_size) * 0.5

	draw_texture_rect_region(atlas, Rect2(draw_pos, draw_size), region)


func _get_frame_at_logical(logical_frame: int):
	if not animation_data or not animation_data.has_method("get_frame_at_index"):
		return null
	return animation_data.get_frame_at_index(logical_frame)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
