@tool
extends Control

## 帧事件轨道 — 绘制 FrameEvent 标记
## 支持：点击选中、双击添加、拖拽移动、Delete 删除

signal event_selected(event_index: int)
signal events_changed()

var events: Array = []:
	set(v):
		events = v
		queue_redraw()
var frame_width: float = 16.0:
	set(v):
		frame_width = v
		queue_redraw()
var current_frame: int = 0:
	set(v):
		current_frame = v
		queue_redraw()
var selected_index: int = -1:
	set(v):
		selected_index = v
		queue_redraw()

var _dragging: bool = false
var _drag_event_index: int = -1


func _ready() -> void:
	custom_minimum_size.y = 28
	focus_mode = Control.FOCUS_CLICK


func _draw() -> void:
	var width := size.x
	var height := size.y

	draw_rect(Rect2(0, 0, width, height), Color(0.2, 0.2, 0.22))

	for i in events.size():
		var ev = events[i]
		if not ev:
			continue
		var f: int = ev.frame
		var x := f * frame_width + frame_width * 0.5
		var y := height * 0.5
		var r := 6.0

		var col: Color
		if i == selected_index:
			col = Color(1.0, 1.0, 0.4)
		else:
			var ev_type: int = ev.type if ev else 0
			match ev_type:
				0: col = Color(0.4, 0.9, 0.4)  # SPAWN_EFFECT
				1: col = Color(0.4, 0.7, 1.0)  # PLAY_SOUND
				2: col = Color(1.0, 0.5, 0.3)  # CAMERA_SHAKE
				_: col = Color(0.7, 0.7, 0.2)

		var pts := PackedVector2Array([
			Vector2(x, y - r),
			Vector2(x + r, y),
			Vector2(x, y + r),
			Vector2(x - r, y)
		])
		draw_colored_polygon(pts, col)
		draw_polyline(pts, Color(1, 1, 1, 0.6))

	# 播放头
	var playhead_x := current_frame * frame_width
	if playhead_x <= width:
		draw_line(Vector2(playhead_x, 0), Vector2(playhead_x, height), Color.RED, 1.0)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			var frame := int(mb.position.x / frame_width)
			if mb.pressed:
				grab_focus()
				if mb.double_click:
					_add_event_at_frame(frame)
					events_changed.emit()
				else:
					var idx := _find_event_near(mb.position.x, mb.position.y)
					if idx >= 0:
						selected_index = idx
						event_selected.emit(idx)
						_dragging = true
						_drag_event_index = idx
					else:
						selected_index = -1
						_dragging = false
				queue_redraw()
			else:
				_dragging = false
				_drag_event_index = -1
			accept_event()
	elif event is InputEventMouseMotion:
		if _dragging and _drag_event_index >= 0 and _drag_event_index < events.size():
			var mm := event as InputEventMouseMotion
			var frame := int(mm.position.x / frame_width)
			frame = maxi(0, frame)
			events[_drag_event_index].frame = frame
			events_changed.emit()
			queue_redraw()
			accept_event()
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and key.keycode == KEY_DELETE:
			_delete_selected()
			accept_event()


func _find_event_near(px: float, py: float) -> int:
	var height := size.y
	var best_idx := -1
	var best_dist := 12.0
	for i in events.size():
		var ev = events[i]
		if not ev:
			continue
		var x: float = ev.frame * frame_width + frame_width * 0.5
		var y: float = height * 0.5
		var dist := Vector2(px - x, py - y).length()
		if dist < best_dist:
			best_dist = dist
			best_idx = i
	return best_idx


func _add_event_at_frame(frame: int) -> void:
	var script := load("res://addons/dnf_framework/resources/skill/frame_event.gd") as GDScript
	if script:
		var ev = script.new()
		ev.frame = frame
		ev.type = 11  # CUSTOM_SIGNAL
		events.append(ev)
		selected_index = events.size() - 1
		event_selected.emit(selected_index)


func _delete_selected() -> void:
	if selected_index >= 0 and selected_index < events.size():
		events.remove_at(selected_index)
		selected_index = -1
		events_changed.emit()
		queue_redraw()
