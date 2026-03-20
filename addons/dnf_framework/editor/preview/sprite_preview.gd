@tool
extends Control

## 精灵预览 — 显示 SpriteFrames 中指定动画的当前帧 + 特效层叠加

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

var skill_data: Resource:
	set(v):
		skill_data = v
		queue_redraw()

var effect_layers: Array = []:
	set(v):
		effect_layers = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size = Vector2(200, 200)


func _draw() -> void:
	var w := size.x
	var h := size.y

	draw_rect(Rect2(0, 0, w, h), Color(0.15, 0.15, 0.15))

	var main_tex := _get_frame_texture(animation_name, current_frame)
	var scale_factor := 1.0
	var center := Vector2(w, h) * 0.5

	if main_tex:
		var src := Vector2(main_tex.get_width(), main_tex.get_height())
		if src.x > 0 and src.y > 0:
			scale_factor = minf((w - 4) / src.x, (h - 4) / src.y)
			var draw_size := src * scale_factor
			var draw_pos := (Vector2(w, h) - draw_size) * 0.5
			draw_texture_rect(main_tex, Rect2(draw_pos, draw_size), false)

	_draw_effect_layers(center, scale_factor)


func _draw_effect_layers(center: Vector2, scale_factor: float) -> void:
	if effect_layers.is_empty() or sprite_frames == null:
		return

	for layer in effect_layers:
		if layer == null:
			continue
		if current_frame < layer.spawn_frame:
			continue
		var local_frame: int = current_frame - layer.spawn_frame
		var layer_anim: String = layer.animation_name
		if layer_anim.is_empty():
			continue
		var tex := _get_frame_texture(layer_anim, local_frame)
		if tex == null:
			continue

		var src := Vector2(tex.get_width(), tex.get_height())
		if src.x <= 0 or src.y <= 0:
			continue

		var draw_size := src * scale_factor
		var offset: Vector2 = layer.offset * scale_factor
		var draw_pos := center + offset - draw_size * 0.5
		draw_texture_rect(tex, Rect2(draw_pos, draw_size), false, Color(0.6, 0.8, 1.0, 0.7))

		var name_pos := Vector2(draw_pos.x, draw_pos.y - 14)
		draw_string(ThemeDB.fallback_font, name_pos, layer.layer_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.4, 0.8, 1.0, 0.8))


func _get_frame_texture(anim_name: String, frame: int) -> Texture2D:
	if sprite_frames == null or anim_name.is_empty():
		return null
	if not sprite_frames.has_animation(anim_name):
		return null
	var count: int = sprite_frames.get_frame_count(anim_name)
	if count <= 0:
		return null
	var idx: int = clampi(frame, 0, count - 1)
	return sprite_frames.get_frame_texture(anim_name, idx)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
