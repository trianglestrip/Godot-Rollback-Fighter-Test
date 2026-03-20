@tool
extends Control

## 精灵预览 — 显示 SpriteFrames 中指定动画的当前帧

var sprite_frames: SpriteFrames:
	set(v):
		sprite_frames = v
		queue_redraw()

var animation_name: String = "":
	set(v):
		animation_name = v
		queue_redraw()

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

	if sprite_frames == null or animation_name.is_empty():
		return
	if not sprite_frames.has_animation(animation_name):
		return

	var frame_count: int = sprite_frames.get_frame_count(animation_name)
	if frame_count <= 0:
		return

	var idx: int = clampi(current_frame, 0, frame_count - 1)
	var tex: Texture2D = sprite_frames.get_frame_texture(animation_name, idx)
	if tex == null:
		return

	var src_size := Vector2(tex.get_width(), tex.get_height())
	if src_size.x <= 0 or src_size.y <= 0:
		return

	var scale_factor := minf((width - 4) / src_size.x, (height - 4) / src_size.y)
	var draw_size := src_size * scale_factor
	var draw_pos := (Vector2(width, height) - draw_size) * 0.5
	draw_texture_rect(tex, Rect2(draw_pos, draw_size), false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
