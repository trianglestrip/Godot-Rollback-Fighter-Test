@tool
extends Control

## 霸体/无敌区间轨道 — 从 FrameEvent 解析 SUPER_ARMOR_START/END、INVINCIBLE_START/END
## 霸体=绿色，无敌=黄色

## 帧事件列表（用于解析霸体/无敌区间）
var events: Array = []:
	set(v):
		events = v
		queue_redraw()
## 每帧像素宽度
var frame_width: float = 16.0:
	set(v):
		frame_width = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size.y = 24


func _draw() -> void:
	var width := size.x
	var height := size.y

	draw_rect(Rect2(0, 0, width, height), Color(0.2, 0.22, 0.2))

	var armor_pairs := _parse_start_end_pairs(5, 6)
	for pair in armor_pairs:
		var x: float = pair[0] * frame_width
		var w := maxf(4.0, (pair[1] - pair[0] + 1) * frame_width)
		draw_rect(Rect2(x, 4, w, height - 8), Color(0.2, 0.7, 0.2))

	var inv_pairs := _parse_start_end_pairs(7, 8)
	for pair in inv_pairs:
		var x: float = pair[0] * frame_width
		var w := maxf(4.0, (pair[1] - pair[0] + 1) * frame_width)
		draw_rect(Rect2(x, 4, w, height - 8), Color(0.8, 0.8, 0.2))


func _parse_start_end_pairs(start_type: int, end_type: int) -> Array:
	var result: Array = []
	var pending_start: int = -1
	var sorted_events := _get_events_sorted_by_frame()
	for ev in sorted_events:
		if not ev:
			continue
		var t: int = ev.type
		var f: int = ev.frame
		if t == start_type:
			pending_start = f
		elif t == end_type and pending_start >= 0:
			result.append([pending_start, f])
			pending_start = -1
	return result


func _get_events_sorted_by_frame() -> Array:
	var copy := events.duplicate()
	copy.sort_custom(func(a, b):
		var fa: int = a.frame if a else 0
		var fb: int = b.frame if b else 0
		return fa < fb
	)
	return copy
