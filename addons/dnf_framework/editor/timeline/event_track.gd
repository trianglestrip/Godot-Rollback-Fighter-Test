@tool
extends Control

## 帧事件轨道 — 绘制 FrameEvent 标记为小圆/菱形
## 点击选中，双击在帧位置添加新事件

signal event_selected(event_index: int)
signal events_changed()

## 帧事件列表（DNFFrameEvent）
var events: Array = []:
	set(v):
		events = v
		queue_redraw()
## 每帧像素宽度
var frame_width: float = 16.0:
	set(v):
		frame_width = v
		queue_redraw()
## 当前选中索引
var selected_index: int = -1:
	set(v):
		selected_index = v
		queue_redraw()


func _ready() -> void:
	custom_minimum_size.y = 28


func _draw() -> void:
	var width := size.x
	var height := size.y

	# 背景
	draw_rect(Rect2(0, 0, width, height), Color(0.2, 0.2, 0.22))

	# 绘制各事件
	for i in events.size():
		var ev = events[i]
		if not ev:
			continue
		var f: int = ev.frame
		var x := f * frame_width + frame_width * 0.5
		var y := height * 0.5
		var col := Color(0.9, 0.9, 0.3) if i == selected_index else Color(0.7, 0.7, 0.2)
		# 菱形
		var r := 6.0
		var pts := PackedVector2Array([
			Vector2(x, y - r),
			Vector2(x + r, y),
			Vector2(x, y + r),
			Vector2(x - r, y)
		])
		draw_colored_polygon(pts, col)
		draw_polyline(pts, Color.WHITE)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			var frame := int(mb.position.x / frame_width)
			if mb.pressed:
				if mb.double_click:
					_add_event_at_frame(frame)
					events_changed.emit()
					accept_event()
				else:
					var idx := _find_event_at_frame(frame)
					selected_index = idx
					if idx >= 0:
						event_selected.emit(idx)
					queue_redraw()
					accept_event()


func _find_event_at_frame(frame: int) -> int:
	for i in events.size():
		var ev = events[i]
		if not ev:
			continue
		var f: int = ev.frame if ev else -1
		if f == frame:
			return i
	return -1


func _add_event_at_frame(frame: int) -> void:
	var script := load("res://addons/dnf_framework/resources/skill/frame_event.gd") as GDScript
	if script:
		var ev = script.new()
		ev.set("frame", frame)
		ev.set("type", 11)  # DNFFrameEvent.EventType.CUSTOM_SIGNAL
		events.append(ev)
		selected_index = events.size() - 1
		event_selected.emit(selected_index)
