@tool
extends VBoxContainer

## DNF 动画 Inspector 控件
## 在 Inspector 面板中显示帧缩略图 + 预览播放 + 时长信息

var _anim: Resource
var _ui_built: bool = false

var _info_label: Label
var _frame_grid: ItemList
var _preview_tex: TextureRect
var _play_btn: Button
var _frame_label: Label
var _speed_scale_spin: SpinBox

var _is_playing: bool = false
var _preview_frame: int = 0
var _preview_timer: float = 0.0


func setup(anim: Resource) -> void:
	_anim = anim


func _ready() -> void:
	_build_ui()
	_ui_built = true
	call_deferred("_deferred_refresh")


func _deferred_refresh() -> void:
	if _anim and _ui_built:
		_refresh()


func _build_ui() -> void:
	var header := Label.new()
	header.text = "▸ DNF 动画预览"
	header.add_theme_font_size_override("font_size", 14)
	add_child(header)

	_info_label = Label.new()
	_info_label.add_theme_font_size_override("font_size", 11)
	_info_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	add_child(_info_label)

	add_child(HSeparator.new())

	var frames_lbl := Label.new()
	frames_lbl.text = "帧列表"
	frames_lbl.add_theme_font_size_override("font_size", 12)
	add_child(frames_lbl)

	_frame_grid = ItemList.new()
	_frame_grid.icon_mode = ItemList.ICON_MODE_TOP
	_frame_grid.max_columns = 0
	_frame_grid.fixed_icon_size = Vector2i(40, 40)
	_frame_grid.custom_minimum_size.y = 100
	_frame_grid.select_mode = ItemList.SELECT_SINGLE
	_frame_grid.item_selected.connect(_on_frame_clicked)
	add_child(_frame_grid)

	add_child(HSeparator.new())

	_preview_tex = TextureRect.new()
	_preview_tex.custom_minimum_size = Vector2(180, 180)
	_preview_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_preview_tex)

	var ctrl_row := HBoxContainer.new()
	var prev_btn := Button.new()
	prev_btn.text = "◀"
	prev_btn.pressed.connect(_on_prev)
	ctrl_row.add_child(prev_btn)
	_play_btn = Button.new()
	_play_btn.text = "▶ 播放"
	_play_btn.pressed.connect(_on_play_toggle)
	ctrl_row.add_child(_play_btn)
	var stop_btn := Button.new()
	stop_btn.text = "■"
	stop_btn.pressed.connect(_on_stop)
	ctrl_row.add_child(stop_btn)
	var next_btn := Button.new()
	next_btn.text = "▶|"
	next_btn.pressed.connect(_on_next)
	ctrl_row.add_child(next_btn)
	add_child(ctrl_row)

	_frame_label = Label.new()
	_frame_label.text = "帧: 0 / 0"
	add_child(_frame_label)

	var speed_row := HBoxContainer.new()
	var speed_lbl := Label.new()
	speed_lbl.text = "速率"
	speed_lbl.custom_minimum_size.x = 35
	speed_row.add_child(speed_lbl)
	_speed_scale_spin = SpinBox.new()
	_speed_scale_spin.min_value = 0.1
	_speed_scale_spin.max_value = 5.0
	_speed_scale_spin.step = 0.1
	_speed_scale_spin.value = 1.0
	_speed_scale_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_speed_scale_spin.value_changed.connect(_on_speed_changed)
	speed_row.add_child(_speed_scale_spin)
	add_child(speed_row)


func _refresh() -> void:
	if _anim == null or not _ui_built:
		return

	var frames_arr: Array = _anim.frames
	var total: int = frames_arr.size()
	var eff_fps: float = _anim.get_effective_fps()
	var duration_s: float = _anim.get_duration_seconds()
	var loop_str: String = "循环" if _anim.loop else "不循环"
	_info_label.text = "%s | %d 帧 | %s | %.1f FPS | %.2f 秒" % [_anim.anim_name, total, loop_str, eff_fps, duration_s]

	_speed_scale_spin.set_value_no_signal(_anim.speed_scale if _anim.speed_scale > 0 else 1.0)

	_frame_grid.clear()
	for i in range(total):
		var fd = frames_arr[i]
		var tex: Texture2D = null
		if fd != null and "texture" in fd:
			tex = fd.texture
		if tex != null:
			_frame_grid.add_item(str(i), tex)
		else:
			_frame_grid.add_item(str(i))

	_preview_frame = 0
	_update_preview()


func _on_speed_changed(val: float) -> void:
	if _anim:
		_anim.speed_scale = val
		var total: int = _anim.frames.size()
		var eff_fps: float = _anim.get_effective_fps()
		var duration_s: float = _anim.get_duration_seconds()
		var loop_str: String = "循环" if _anim.loop else "不循环"
		_info_label.text = "%s | %d 帧 | %s | %.1f FPS | %.2f 秒" % [_anim.anim_name, total, loop_str, eff_fps, duration_s]


func _on_frame_clicked(idx: int) -> void:
	_is_playing = false
	_play_btn.text = "▶ 播放"
	_preview_frame = idx
	_update_preview()


func _on_play_toggle() -> void:
	if _anim == null or _anim.frames.is_empty():
		return
	_is_playing = not _is_playing
	_play_btn.text = "⏸ 暂停" if _is_playing else "▶ 播放"
	if _is_playing:
		_preview_timer = 0.0


func _on_stop() -> void:
	_is_playing = false
	_play_btn.text = "▶ 播放"
	_preview_timer = 0.0
	_preview_frame = 0
	_update_preview()


func _on_prev() -> void:
	if _anim == null or _anim.frames.is_empty():
		return
	_preview_frame = (_preview_frame - 1 + _anim.frames.size()) % _anim.frames.size()
	_update_preview()


func _on_next() -> void:
	if _anim == null or _anim.frames.is_empty():
		return
	_preview_frame = (_preview_frame + 1) % _anim.frames.size()
	_update_preview()


func _process(delta: float) -> void:
	if not _is_playing or _anim == null or _anim.frames.is_empty():
		return
	var eff_fps: float = _anim.get_effective_fps()
	if eff_fps <= 0:
		return
	_preview_timer += delta
	var interval: float = 1.0 / eff_fps
	while _preview_timer >= interval:
		_preview_timer -= interval
		_preview_frame += 1
		if _preview_frame >= _anim.frames.size():
			if _anim.loop:
				_preview_frame = 0
			else:
				_preview_frame = _anim.frames.size() - 1
				_is_playing = false
				_play_btn.text = "▶ 播放"
				break
	_update_preview()


func _update_preview() -> void:
	if not _ui_built:
		return
	if _anim == null or _anim.frames.is_empty():
		if _preview_tex:
			_preview_tex.texture = null
		if _frame_label:
			_frame_label.text = "帧: 0 / 0"
		return
	var frames_arr: Array = _anim.frames
	var total: int = frames_arr.size()
	_preview_frame = clampi(_preview_frame, 0, total - 1)
	var fd = frames_arr[_preview_frame]
	var tex: Texture2D = null
	if fd != null and "texture" in fd:
		tex = fd.texture
	if tex != null:
		_preview_tex.texture = tex
	else:
		_preview_tex.texture = null
	_frame_label.text = "帧: %d / %d" % [_preview_frame + 1, total]
	if _preview_frame < _frame_grid.item_count:
		_frame_grid.deselect_all()
		_frame_grid.select(_preview_frame)
		_frame_grid.ensure_current_is_visible()
