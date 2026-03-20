@tool
extends Control

## 攻击区间轨道 — 绘制 AttackPhase 区间为彩色矩形
## 支持：拖拽创建新区间、拖拽边缘调整、拖拽中间移动、点击选中、Delete 删除

signal phase_selected(phase_index: int)
signal phases_changed()

var phases: Array = []:
	set(v):
		phases = v
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

var _drag_mode: int = 0  # 0=none 1=create 2=move 3=left-edge 4=right-edge
var _drag_start_x: float = 0.0
var _drag_start_frame: int = 0
var _drag_phase_index: int = -1


func _ready() -> void:
	custom_minimum_size.y = 32
	focus_mode = Control.FOCUS_CLICK


func _draw() -> void:
	var width := size.x
	var height := size.y

	draw_rect(Rect2(0, 0, width, height), Color(0.2, 0.22, 0.2))

	for i in phases.size():
		var phase = phases[i]
		if not phase:
			continue
		var start_f: int = phase.start_frame
		var end_f: int = phase.end_frame
		var x := start_f * frame_width
		var w := maxf(4.0, (end_f - start_f + 1) * frame_width)
		var col := Color(0.9, 0.5, 0.2) if i == selected_index else Color(0.6, 0.3, 0.15)
		draw_rect(Rect2(x, 4, w, height - 8), col)
		draw_rect(Rect2(x, 4, w, height - 8), Color(1, 1, 1, 0.3), false)

		var label_text := "P%d" % i
		var font: Font = ThemeDB.fallback_font
		var font_size: int = 10
		if font and w > 20:
			draw_string(font, Vector2(x + 3, height - 8), label_text, HORIZONTAL_ALIGNMENT_LEFT, int(w) - 6, font_size)

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
				_handle_mouse_press(mb.position.x, frame)
			else:
				_handle_mouse_release(mb.position.x, frame)
			accept_event()
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		_handle_mouse_motion(mm.position.x)
		accept_event()
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and key.keycode == KEY_DELETE:
			_delete_selected()
			accept_event()


func _handle_mouse_press(local_x: float, frame: int) -> void:
	grab_focus()
	_drag_start_x = local_x
	_drag_start_frame = frame

	var hit_idx := _find_phase_at_frame(frame)
	if hit_idx >= 0:
		var phase = phases[hit_idx]
		var start_f: int = phase.start_frame
		var end_f: int = phase.end_frame
		var left_x := start_f * frame_width
		var right_x := (end_f + 1) * frame_width
		var edge_thresh := 8.0
		if abs(local_x - left_x) < edge_thresh:
			_drag_mode = 3
			_drag_phase_index = hit_idx
			return
		if abs(local_x - right_x) < edge_thresh:
			_drag_mode = 4
			_drag_phase_index = hit_idx
			return
		_drag_mode = 2
		_drag_phase_index = hit_idx
		selected_index = hit_idx
		phase_selected.emit(hit_idx)
		return

	_drag_mode = 1
	_drag_phase_index = -1
	selected_index = -1


func _handle_mouse_release(_local_x: float, frame: int) -> void:
	if _drag_mode == 1:
		var start_f := mini(_drag_start_frame, frame)
		var end_f := maxi(_drag_start_frame, frame)
		if end_f > start_f:
			_create_phase(start_f, end_f)
			phases_changed.emit()

	_drag_mode = 0
	_drag_phase_index = -1
	queue_redraw()


func _handle_mouse_motion(local_x: float) -> void:
	var frame := int(local_x / frame_width)
	if _drag_mode == 1:
		queue_redraw()
	elif _drag_mode == 2 and _drag_phase_index >= 0 and _drag_phase_index < phases.size():
		var phase = phases[_drag_phase_index]
		var start_f: int = phase.start_frame
		var end_f: int = phase.end_frame
		var delta := frame - _drag_start_frame
		var new_start: int = start_f + delta
		var new_end: int = end_f + delta
		if new_start >= 0:
			phase.start_frame = new_start
			phase.end_frame = new_end
			_drag_start_frame = frame
			phases_changed.emit()
			queue_redraw()
	elif _drag_mode == 3 and _drag_phase_index >= 0 and _drag_phase_index < phases.size():
		var phase = phases[_drag_phase_index]
		var end_f: int = phase.end_frame
		if frame < end_f:
			phase.start_frame = frame
			phases_changed.emit()
			queue_redraw()
	elif _drag_mode == 4 and _drag_phase_index >= 0 and _drag_phase_index < phases.size():
		var phase = phases[_drag_phase_index]
		var start_f: int = phase.start_frame
		if frame > start_f:
			phase.end_frame = frame
			phases_changed.emit()
			queue_redraw()


func _find_phase_at_frame(frame: int) -> int:
	for i in phases.size():
		var phase = phases[i]
		if not phase:
			continue
		var start_f: int = phase.start_frame
		var end_f: int = phase.end_frame
		if frame >= start_f and frame <= end_f:
			return i
	return -1


func _create_phase(start_f: int, end_f: int) -> void:
	var script := load("res://addons/dnf_framework/resources/skill/attack_phase.gd") as GDScript
	if script:
		var phase = script.new()
		phase.start_frame = start_f
		phase.end_frame = end_f
		phases.append(phase)
		selected_index = phases.size() - 1
		phase_selected.emit(selected_index)


func _delete_selected() -> void:
	if selected_index >= 0 and selected_index < phases.size():
		phases.remove_at(selected_index)
		selected_index = -1
		phases_changed.emit()
		queue_redraw()
