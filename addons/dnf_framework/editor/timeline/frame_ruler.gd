@tool
extends Control

## 帧标尺 — 绘制帧刻度与播放头
## 每5帧主刻度带数字，每帧次刻度；红色播放头线；点击可设置当前帧

signal frame_clicked(frame: int)

## 总帧数
var total_frames: int = 60
## 当前帧
var current_frame: int = 0
## 每帧像素宽度
var frame_width: float = 16.0


func _ready() -> void:
	custom_minimum_size.y = 30


func _draw() -> void:
	var width := size.x
	var height := size.y

	# 背景
	draw_rect(Rect2(0, 0, width, height), Color(0.2, 0.2, 0.2))

	# 次刻度（每帧）
	for f in range(total_frames + 1):
		var x := f * frame_width
		if x > width:
			break
		var tick_h := 6.0 if f % 5 != 0 else 12.0
		draw_line(Vector2(x, height), Vector2(x, height - tick_h), Color(0.5, 0.5, 0.5))

	for f in range(0, total_frames + 1, 5):
		var x := f * frame_width
		if x > width:
			break
		var font: Font = ThemeDB.fallback_font
		var font_size: int = ThemeDB.fallback_font_size
		if font:
			draw_string(font, Vector2(x + 2, height - 10), str(f), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)

	# 播放头红线
	var playhead_x := current_frame * frame_width
	if playhead_x <= width:
		draw_line(Vector2(playhead_x, 0), Vector2(playhead_x, height), Color.RED)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var frame := int(mb.position.x / frame_width)
			frame = clampi(frame, 0, total_frames)
			frame_clicked.emit(frame)
			accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
