@tool
extends Control

## 时间轴主面板 — 包含所有轨道和标尺
## Phase 10 Timeline 编辑器根节点

signal frame_changed(frame: int)
signal playback_toggled(playing: bool)

## 总帧数
var total_frames: int = 60:
	set(v):
		total_frames = maxi(1, v)
		_queue_redraw_all()
## 当前帧
var current_frame: int = 0:
	set(v):
		current_frame = clampi(v, 0, total_frames)
		frame_changed.emit(current_frame)
		_queue_redraw_all()
## 每帧像素宽度
var frame_width: float = 16.0:
	set(v):
		frame_width = maxf(4.0, v)
		_queue_redraw_all()
## 缩放
var zoom: float = 1.0:
	set(v):
		zoom = clampf(v, 0.25, 4.0)
		frame_width = 16.0 * zoom
		_queue_redraw_all()
## 帧率（用于播放）
var fps: int = 12

## 是否正在播放
var _playing: bool = false
## 播放累计时间
var _play_accum: float = 0.0

## 子控件引用
var _toolbar: HBoxContainer
var _play_btn: Button
var _frame_label: Label
var _zoom_slider: HSlider
var _total_spinbox: SpinBox
var _frame_ruler: Control
var _track_container: VBoxContainer
var _scroll: ScrollContainer

## 当前加载的技能数据
var _skill_data: Resource


func _ready() -> void:
	_build_ui()


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	if _playing:
		_play_accum += delta
		var frame_time := 1.0 / maxi(1, fps)
		while _play_accum >= frame_time:
			_play_accum -= frame_time
			current_frame += 1
			if current_frame >= total_frames:
				current_frame = 0


func _build_ui() -> void:
	# 清空已有子节点
	for c in get_children():
		c.queue_free()

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	# 工具栏
	_toolbar = HBoxContainer.new()
	_toolbar.add_theme_constant_override("separation", 8)
	vbox.add_child(_toolbar)

	_play_btn = Button.new()
	_play_btn.text = "▶"
	_play_btn.tooltip_text = "播放/暂停"
	_play_btn.pressed.connect(_on_play_pressed)
	_toolbar.add_child(_play_btn)

	_frame_label = Label.new()
	_frame_label.text = "帧: 0"
	_frame_label.custom_minimum_size.x = 80
	_toolbar.add_child(_frame_label)

	_zoom_slider = HSlider.new()
	_zoom_slider.min_value = 0.25
	_zoom_slider.max_value = 4.0
	_zoom_slider.step = 0.25
	_zoom_slider.value = zoom
	_zoom_slider.custom_minimum_size.x = 100
	_zoom_slider.value_changed.connect(_on_zoom_changed)
	_toolbar.add_child(_zoom_slider)

	var total_label := Label.new()
	total_label.text = "总帧:"
	_toolbar.add_child(total_label)

	_total_spinbox = SpinBox.new()
	_total_spinbox.min_value = 1
	_total_spinbox.max_value = 9999
	_total_spinbox.value = total_frames
	_total_spinbox.custom_minimum_size.x = 80
	_total_spinbox.value_changed.connect(_on_total_frames_changed)
	_toolbar.add_child(_total_spinbox)

	# 标尺
	_frame_ruler = _create_frame_ruler()
	vbox.add_child(_frame_ruler)
	if _frame_ruler.has_signal("frame_clicked"):
		_frame_ruler.frame_clicked.connect(_on_frame_ruler_clicked)

	# 轨道容器（带滚动）
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_scroll)

	_track_container = VBoxContainer.new()
	_track_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_track_container)

	_update_ui_from_props()


func _create_frame_ruler() -> Control:
	var script := load("res://addons/dnf_framework/editor/timeline/frame_ruler.gd") as GDScript
	if script:
		var ruler := Control.new()
		ruler.set_script(script)
		ruler.custom_minimum_size.y = 30
		return ruler
	return Control.new()


func _update_ui_from_props() -> void:
	if _frame_label:
		_frame_label.text = "帧: %d" % current_frame
	if _zoom_slider:
		_zoom_slider.value = zoom
	if _total_spinbox:
		_total_spinbox.value = total_frames
	_propagate_props_to_tracks()


func _propagate_props_to_tracks() -> void:
	if _track_container:
		_track_container.custom_minimum_size.x = total_frames * frame_width
	if _frame_ruler and _frame_ruler.get("total_frames") != null:
		_frame_ruler.total_frames = total_frames
		_frame_ruler.current_frame = current_frame
		_frame_ruler.frame_width = frame_width
	for child in _track_container.get_children() if _track_container else []:
		if child.get("frame_width") != null:
			child.frame_width = frame_width
		if child.get("current_frame") != null:
			child.current_frame = current_frame


func _queue_redraw_all() -> void:
	if not is_node_ready():
		return
	_update_ui_from_props()
	if _frame_ruler:
		_frame_ruler.queue_redraw()
	for child in _track_container.get_children() if _track_container else []:
		child.queue_redraw()


func _on_play_pressed() -> void:
	_playing = not _playing
	_play_btn.text = "⏸" if _playing else "▶"
	playback_toggled.emit(_playing)


func _on_zoom_changed(value: float) -> void:
	zoom = value


func _on_total_frames_changed(value: float) -> void:
	total_frames = int(value)


func _on_frame_ruler_clicked(frame: int) -> void:
	current_frame = frame


## 加载技能数据并填充轨道
func set_skill_data(skill: Resource) -> void:
	_skill_data = skill
	if not _track_container:
		return
	for c in _track_container.get_children():
		c.queue_free()

	if not skill:
		total_frames = 60
		_queue_redraw_all()
		return

	var anim: Resource = skill.animation if "animation" in skill else null
	if anim and anim.has_method("get_total_frames"):
		total_frames = anim.get_total_frames()
	else:
		total_frames = 60

	var phase_script := load("res://addons/dnf_framework/editor/timeline/phase_track.gd") as GDScript
	var event_script := load("res://addons/dnf_framework/editor/timeline/event_track.gd") as GDScript
	var move_script := load("res://addons/dnf_framework/editor/timeline/movement_track.gd") as GDScript
	var armor_script := load("res://addons/dnf_framework/editor/timeline/armor_track.gd") as GDScript

	if phase_script:
		var pt := Control.new()
		pt.set_script(phase_script)
		pt.custom_minimum_size.y = 32
		pt.phases = skill.phases
		pt.frame_width = frame_width
		pt.phase_selected.connect(_on_phase_selected)
		pt.phases_changed.connect(_on_phases_changed)
		_track_container.add_child(pt)

	if event_script:
		var evt := Control.new()
		evt.set_script(event_script)
		evt.custom_minimum_size.y = 28
		var all_events: Array = []
		all_events.append_array(skill.events)
		for p in skill.phases:
			if p and not p.events.is_empty():
				all_events.append_array(p.events)
		evt.events = all_events
		evt.frame_width = frame_width
		evt.event_selected.connect(_on_event_selected)
		evt.events_changed.connect(_on_events_changed)
		_track_container.add_child(evt)

	if move_script:
		var mt := Control.new()
		mt.set_script(move_script)
		mt.custom_minimum_size.y = 28
		mt.movements = skill.movement
		mt.frame_width = frame_width
		mt.movement_selected.connect(_on_movement_selected)
		mt.movements_changed.connect(_on_movements_changed)
		_track_container.add_child(mt)

	if armor_script:
		var at := Control.new()
		at.set_script(armor_script)
		at.custom_minimum_size.y = 24
		at.events = skill.events
		at.frame_width = frame_width
		_track_container.add_child(at)

	_propagate_props_to_tracks()
	_queue_redraw_all()


func _on_phase_selected(_idx: int) -> void:
	pass


func _on_phases_changed() -> void:
	_queue_redraw_all()


func _on_event_selected(_idx: int) -> void:
	pass


func _on_events_changed() -> void:
	_queue_redraw_all()


func _on_movement_selected(_idx: int) -> void:
	pass


func _on_movements_changed() -> void:
	_queue_redraw_all()
