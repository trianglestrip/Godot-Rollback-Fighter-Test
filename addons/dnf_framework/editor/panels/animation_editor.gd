@tool
extends Control

## DNF 动画编辑器 — 素材池 + 动画序列 工作流
##
## 上半部分：素材池（从文件夹加载所有 PNG，支持 Ctrl/Shift 多选）
## 下半部分：动画序列（从素材池挑选出的帧，可排序）
## 右侧：预览播放 + 属性设置
##
## 播放模型：播放时间 = 帧数 / (fps × speed_scale)
## 4帧动画 vs 8帧动画，同 fps 下播放时间就是 1:2

const AnimationData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")
const FrameDataRes = preload("res://addons/dnf_framework/resources/animation/frame_data.gd")

signal animation_saved(path: String)

var _current_anim: Resource
var _pool_items: Array = []

var _pool_list: ItemList
var _pool_label: Label
var _seq_list: ItemList
var _seq_label: Label

var _anim_name_edit: LineEdit
var _loop_check: CheckBox
var _fps_spin: SpinBox
var _speed_scale_spin: SpinBox
var _duration_label: Label

var _preview_texture: TextureRect
var _play_btn: Button
var _frame_label: Label
var _status_label: Label

var _is_playing: bool = false
var _preview_frame: int = 0
var _preview_timer: float = 0.0

var _file_dialog: FileDialog


func _ready() -> void:
	_build_ui()
	_new_animation()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var root := HSplitContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	## ========== 左大区：素材池 + 动画序列 ==========
	var left_main := VSplitContainer.new()
	left_main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(left_main)

	## ----- 上方：素材池 -----
	var pool_box := VBoxContainer.new()
	pool_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_main.add_child(pool_box)

	var pool_header := HBoxContainer.new()
	_pool_label = Label.new()
	_pool_label.text = "素材池 (0)"
	_pool_label.add_theme_font_size_override("font_size", 13)
	_pool_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pool_header.add_child(_pool_label)

	var btn_load_folder := Button.new()
	btn_load_folder.text = "加载文件夹"
	btn_load_folder.pressed.connect(_on_load_folder)
	pool_header.add_child(btn_load_folder)

	var btn_pool_add_files := Button.new()
	btn_pool_add_files.text = "加载文件"
	btn_pool_add_files.pressed.connect(_on_load_files)
	pool_header.add_child(btn_pool_add_files)

	var btn_pool_clear := Button.new()
	btn_pool_clear.text = "清空素材池"
	btn_pool_clear.pressed.connect(_on_pool_clear)
	pool_header.add_child(btn_pool_clear)
	pool_box.add_child(pool_header)

	_pool_list = ItemList.new()
	_pool_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_pool_list.icon_mode = ItemList.ICON_MODE_TOP
	_pool_list.max_columns = 0
	_pool_list.fixed_icon_size = Vector2i(48, 48)
	_pool_list.select_mode = ItemList.SELECT_MULTI
	_pool_list.item_activated.connect(_on_pool_double_click)
	pool_box.add_child(_pool_list)

	var pool_btns := HBoxContainer.new()
	var btn_add_sel := Button.new()
	btn_add_sel.text = "▼ 添加选中到序列"
	btn_add_sel.pressed.connect(_on_add_selected_to_seq)
	pool_btns.add_child(btn_add_sel)
	var btn_add_all := Button.new()
	btn_add_all.text = "▼ 全部添加"
	btn_add_all.pressed.connect(_on_add_all_to_seq)
	pool_btns.add_child(btn_add_all)
	var hint := Label.new()
	hint.text = "  Ctrl+点击 多选 | Shift+点击 范围选 | 双击 单个添加"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	pool_btns.add_child(hint)
	pool_box.add_child(pool_btns)

	## ----- 下方：动画序列 -----
	var seq_box := VBoxContainer.new()
	seq_box.custom_minimum_size.y = 140
	left_main.add_child(seq_box)

	var seq_header := HBoxContainer.new()
	_seq_label = Label.new()
	_seq_label.text = "动画序列 (0 帧)"
	_seq_label.add_theme_font_size_override("font_size", 13)
	_seq_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seq_header.add_child(_seq_label)

	for btn_info in [
		["清空序列", _on_seq_clear],
		["删除选中", _on_seq_delete],
		["← 左移", _on_seq_move_left],
		["→ 右移", _on_seq_move_right],
	]:
		var btn := Button.new()
		btn.text = btn_info[0]
		btn.pressed.connect(btn_info[1])
		seq_header.add_child(btn)
	seq_box.add_child(seq_header)

	_seq_list = ItemList.new()
	_seq_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_seq_list.icon_mode = ItemList.ICON_MODE_TOP
	_seq_list.max_columns = 0
	_seq_list.fixed_icon_size = Vector2i(48, 48)
	_seq_list.select_mode = ItemList.SELECT_MULTI
	_seq_list.item_selected.connect(_on_seq_item_selected)
	seq_box.add_child(_seq_list)

	## ========== 右侧：属性 + 预览 ==========
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 250
	root.add_child(right)

	var action_row := HBoxContainer.new()
	var btn_new := Button.new()
	btn_new.text = "新建"
	btn_new.pressed.connect(_on_new)
	action_row.add_child(btn_new)
	var btn_save := Button.new()
	btn_save.text = "保存 .tres"
	btn_save.pressed.connect(_on_save)
	action_row.add_child(btn_save)
	var btn_load := Button.new()
	btn_load.text = "加载 .tres"
	btn_load.pressed.connect(_on_load)
	action_row.add_child(btn_load)
	right.add_child(action_row)

	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 11)
	_status_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	right.add_child(_status_label)

	_anim_name_edit = LineEdit.new()
	_anim_name_edit.placeholder_text = "动画名 (idle / walk / ...)"
	_anim_name_edit.text_changed.connect(_on_name_changed)
	right.add_child(_make_row("名称", _anim_name_edit))

	var opts_row := HBoxContainer.new()
	_loop_check = CheckBox.new()
	_loop_check.text = "循环"
	_loop_check.toggled.connect(_on_loop_toggled)
	opts_row.add_child(_loop_check)

	opts_row.add_child(_make_label(" 帧率"))
	_fps_spin = SpinBox.new()
	_fps_spin.min_value = 1
	_fps_spin.max_value = 120
	_fps_spin.value = 12
	_fps_spin.custom_minimum_size.x = 55
	_fps_spin.value_changed.connect(_on_fps_changed)
	opts_row.add_child(_fps_spin)

	opts_row.add_child(_make_label(" 速率"))
	_speed_scale_spin = SpinBox.new()
	_speed_scale_spin.min_value = 0.1
	_speed_scale_spin.max_value = 5.0
	_speed_scale_spin.step = 0.1
	_speed_scale_spin.value = 1.0
	_speed_scale_spin.custom_minimum_size.x = 55
	_speed_scale_spin.value_changed.connect(_on_speed_scale_changed)
	opts_row.add_child(_speed_scale_spin)
	right.add_child(opts_row)

	_duration_label = Label.new()
	_duration_label.add_theme_font_size_override("font_size", 11)
	_duration_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	right.add_child(_duration_label)

	right.add_child(HSeparator.new())

	## 预览区
	var preview_panel := PanelContainer.new()
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview_texture = TextureRect.new()
	_preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_panel.add_child(_preview_texture)
	right.add_child(preview_panel)

	var ctrl_row := HBoxContainer.new()
	var prev_btn := Button.new()
	prev_btn.text = "◀"
	prev_btn.pressed.connect(_on_prev_frame)
	ctrl_row.add_child(prev_btn)
	_play_btn = Button.new()
	_play_btn.text = "▶"
	_play_btn.pressed.connect(_on_play_toggle)
	ctrl_row.add_child(_play_btn)
	var stop_btn := Button.new()
	stop_btn.text = "■"
	stop_btn.pressed.connect(_on_stop)
	ctrl_row.add_child(stop_btn)
	var next_btn := Button.new()
	next_btn.text = "▶|"
	next_btn.pressed.connect(_on_next_frame)
	ctrl_row.add_child(next_btn)
	right.add_child(ctrl_row)

	_frame_label = Label.new()
	_frame_label.text = "帧: 0 / 0"
	right.add_child(_frame_label)

	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.size = Vector2i(800, 500)
	add_child(_file_dialog)


func _make_row(lbl_text: String, ctrl: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = lbl_text
	lbl.custom_minimum_size.x = 40
	row.add_child(lbl)
	ctrl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(ctrl)
	return row

func _make_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	return lbl

func _set_status(text: String) -> void:
	if _status_label:
		_status_label.text = text

func _update_duration_label() -> void:
	if _current_anim == null or _duration_label == null:
		return
	var n: int = _current_anim.frames.size()
	var eff_fps: float = _current_anim.get_effective_fps()
	if n == 0 or eff_fps <= 0:
		_duration_label.text = ""
		return
	var secs: float = float(n) / eff_fps
	_duration_label.text = "%d 帧 | 实际 %.1f FPS | 时长 %.2f 秒" % [n, eff_fps, secs]

func _disconnect_all() -> void:
	for sig_name in ["files_selected", "dir_selected", "file_selected"]:
		var sig: Signal = _file_dialog.get(sig_name) as Signal
		if sig == null:
			continue
		for conn in sig.get_connections():
			sig.disconnect(conn.callable)


## =====================================================
## 素材池
## =====================================================

func _on_load_folder() -> void:
	_disconnect_all()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_file_dialog.title = "选择帧图片所在文件夹"
	_file_dialog.dir_selected.connect(_on_folder_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_load_files() -> void:
	_disconnect_all()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	_file_dialog.filters = PackedStringArray(["*.png ; PNG 图片"])
	_file_dialog.title = "选择帧图片 (可多选)"
	_file_dialog.files_selected.connect(_on_pool_files_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_folder_selected(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		_set_status("无法打开目录")
		return
	var file_names: Array[String] = []
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			var ext := fname.get_extension().to_lower()
			if ext == "png":
				if not file_names.has(fname):
					file_names.append(fname)
			elif ext == "import":
				var base := fname.get_basename()
				if base.get_extension().to_lower() == "png":
					if not file_names.has(base):
						file_names.append(base)
		fname = dir.get_next()
	dir.list_dir_end()
	file_names.sort()
	_pool_items.clear()
	for fn in file_names:
		var full_path := dir_path.path_join(fn)
		var tex := load(full_path) as Texture2D
		if tex:
			_pool_items.append({ "path": full_path, "texture": tex, "name": fn })
	_refresh_pool()
	_set_status("加载了 %d 张图片" % _pool_items.size())

func _on_pool_files_selected(paths: PackedStringArray) -> void:
	var sorted: Array[String] = []
	for p in paths:
		sorted.append(p)
	sorted.sort()
	for path in sorted:
		var tex := load(path) as Texture2D
		if tex:
			_pool_items.append({ "path": path, "texture": tex, "name": path.get_file() })
	_refresh_pool()
	_set_status("素材池: %d 张" % _pool_items.size())

func _on_pool_clear() -> void:
	_pool_items.clear()
	_refresh_pool()
	_set_status("素材池已清空")

func _refresh_pool() -> void:
	_pool_list.clear()
	for i in range(_pool_items.size()):
		var item = _pool_items[i]
		_pool_list.add_item(item.name.get_basename(), item.texture)
	_pool_label.text = "素材池 (%d)" % _pool_items.size()

func _on_pool_double_click(idx: int) -> void:
	if idx >= 0 and idx < _pool_items.size():
		_add_pool_items_to_seq([idx])

func _on_add_selected_to_seq() -> void:
	var sel := _pool_list.get_selected_items()
	if sel.is_empty():
		_set_status("请先在素材池中选择图片")
		return
	var indices: Array[int] = []
	for s in sel:
		indices.append(s)
	indices.sort()
	_add_pool_items_to_seq(indices)

func _on_add_all_to_seq() -> void:
	if _pool_items.is_empty():
		return
	var indices: Array[int] = []
	for i in range(_pool_items.size()):
		indices.append(i)
	_add_pool_items_to_seq(indices)

func _add_pool_items_to_seq(pool_indices: Array[int]) -> void:
	if _current_anim == null:
		return
	var count := 0
	for idx in pool_indices:
		if idx < 0 or idx >= _pool_items.size():
			continue
		var item = _pool_items[idx]
		var fd := FrameDataRes.new()
		fd.texture = item.texture
		fd.duration = 1
		_current_anim.frames.append(fd)
		count += 1
	_refresh_seq()
	_update_duration_label()
	_set_status("添加了 %d 帧到序列" % count)


## =====================================================
## 动画序列
## =====================================================

func _refresh_seq() -> void:
	_seq_list.clear()
	if _current_anim == null:
		return
	var frames: Array = _current_anim.frames
	for i in range(frames.size()):
		var fd = frames[i]
		if fd.texture:
			_seq_list.add_item(str(i), fd.texture)
		else:
			_seq_list.add_item(str(i))
	_seq_label.text = "动画序列 (%d 帧)" % frames.size()
	_update_duration_label()

func _on_seq_item_selected(idx: int) -> void:
	if _current_anim == null:
		return
	var frames: Array = _current_anim.frames
	if idx >= 0 and idx < frames.size():
		var fd = frames[idx]
		if fd.texture:
			_preview_texture.texture = fd.texture

func _on_seq_clear() -> void:
	if _current_anim == null:
		return
	_current_anim.frames.clear()
	_refresh_seq()
	_stop_playback()
	_set_status("序列已清空")

func _on_seq_delete() -> void:
	if _current_anim == null:
		return
	var sel := _seq_list.get_selected_items()
	if sel.is_empty():
		return
	var sorted_sel: Array[int] = []
	for s in sel:
		sorted_sel.append(s)
	sorted_sel.sort()
	sorted_sel.reverse()
	for idx in sorted_sel:
		if idx >= 0 and idx < _current_anim.frames.size():
			_current_anim.frames.remove_at(idx)
	_refresh_seq()
	_set_status("删除了 %d 帧" % sorted_sel.size())

func _on_seq_move_left() -> void:
	_seq_move(-1)
func _on_seq_move_right() -> void:
	_seq_move(1)

func _seq_move(direction: int) -> void:
	if _current_anim == null:
		return
	var sel := _seq_list.get_selected_items()
	if sel.is_empty():
		return
	var indices: Array[int] = []
	for s in sel:
		indices.append(s)
	indices.sort()
	var frames: Array = _current_anim.frames
	if direction < 0:
		if indices[0] <= 0:
			return
		for idx in indices:
			var ni: int = idx + direction
			var tmp = frames[idx]
			frames[idx] = frames[ni]
			frames[ni] = tmp
	else:
		if indices[indices.size() - 1] >= frames.size() - 1:
			return
		indices.reverse()
		for idx in indices:
			var ni: int = idx + direction
			var tmp = frames[idx]
			frames[idx] = frames[ni]
			frames[ni] = tmp
	_refresh_seq()
	for idx in indices:
		var ni: int = idx + direction
		if ni >= 0 and ni < frames.size():
			_seq_list.select(ni, true)


## =====================================================
## 动画属性
## =====================================================

func _new_animation() -> void:
	_current_anim = AnimationData.new()
	_current_anim.anim_name = ""
	_current_anim.fps = 12
	_current_anim.speed_scale = 1.0
	_current_anim.loop = false
	_current_anim.frames = []
	_refresh_all()
	_set_status("已新建空动画")

func _refresh_all() -> void:
	if _current_anim == null:
		return
	_anim_name_edit.text = _current_anim.anim_name
	_loop_check.button_pressed = _current_anim.loop
	_fps_spin.value = _current_anim.fps
	_speed_scale_spin.value = _current_anim.speed_scale
	_refresh_seq()
	_stop_playback()
	_update_duration_label()

func _on_name_changed(new_text: String) -> void:
	if _current_anim:
		_current_anim.anim_name = new_text

func _on_loop_toggled(pressed: bool) -> void:
	if _current_anim:
		_current_anim.loop = pressed

func _on_fps_changed(val: float) -> void:
	if _current_anim:
		_current_anim.fps = int(val)
		_update_duration_label()

func _on_speed_scale_changed(val: float) -> void:
	if _current_anim:
		_current_anim.speed_scale = val
		_update_duration_label()


## =====================================================
## 保存 / 加载
## =====================================================

func _on_new() -> void:
	_new_animation()

func _on_save() -> void:
	if _current_anim == null:
		return
	if _current_anim.frames.is_empty():
		_set_status("序列为空，无法保存")
		return
	_disconnect_all()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.filters = PackedStringArray(["*.tres ; Godot 资源"])
	_file_dialog.title = "保存动画资源"
	if not _current_anim.anim_name.is_empty():
		_file_dialog.current_file = _current_anim.anim_name + ".tres"
	_file_dialog.file_selected.connect(_on_save_path, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_save_path(path: String) -> void:
	if _current_anim == null:
		return
	var err := ResourceSaver.save(_current_anim, path)
	if err == OK:
		animation_saved.emit(path)
		_set_status("已保存: " + path.get_file())
		_new_animation()
	else:
		_set_status("保存失败! 错误码: %d" % err)

func _on_load() -> void:
	_disconnect_all()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.filters = PackedStringArray(["*.tres ; Godot 资源"])
	_file_dialog.title = "加载动画资源"
	_file_dialog.file_selected.connect(_on_load_path, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_load_path(path: String) -> void:
	var res := load(path)
	if res == null:
		_set_status("加载失败: " + path)
		return
	_current_anim = res
	_refresh_all()
	_set_status("已加载: " + path.get_file())


## =====================================================
## 预览播放
## =====================================================

func _on_play_toggle() -> void:
	if _current_anim == null or _current_anim.frames.is_empty():
		return
	_is_playing = not _is_playing
	_play_btn.text = "⏸" if _is_playing else "▶"
	if _is_playing:
		_preview_timer = 0.0

func _on_stop() -> void:
	_stop_playback()

func _stop_playback() -> void:
	_is_playing = false
	if _play_btn:
		_play_btn.text = "▶"
	_preview_timer = 0.0
	_preview_frame = 0
	_update_preview()

func _on_prev_frame() -> void:
	if _current_anim == null or _current_anim.frames.is_empty():
		return
	_preview_frame = (_preview_frame - 1 + _current_anim.frames.size()) % _current_anim.frames.size()
	_update_preview()

func _on_next_frame() -> void:
	if _current_anim == null or _current_anim.frames.is_empty():
		return
	_preview_frame = (_preview_frame + 1) % _current_anim.frames.size()
	_update_preview()

func _process(delta: float) -> void:
	if not _is_playing or _current_anim == null or _current_anim.frames.is_empty():
		return
	var eff_fps: float = _current_anim.get_effective_fps()
	if eff_fps <= 0:
		return
	_preview_timer += delta
	var interval: float = 1.0 / eff_fps
	while _preview_timer >= interval:
		_preview_timer -= interval
		_preview_frame += 1
		if _preview_frame >= _current_anim.frames.size():
			if _current_anim.loop:
				_preview_frame = 0
			else:
				_preview_frame = _current_anim.frames.size() - 1
				_is_playing = false
				_play_btn.text = "▶"
				break
		_update_preview()

func _update_preview() -> void:
	if _current_anim == null or _current_anim.frames.is_empty():
		if _preview_texture:
			_preview_texture.texture = null
		if _frame_label:
			_frame_label.text = "帧: 0 / 0"
		return
	var total: int = _current_anim.frames.size()
	_preview_frame = clampi(_preview_frame, 0, total - 1)
	var fd = _current_anim.frames[_preview_frame]
	if fd.texture:
		_preview_texture.texture = fd.texture
	else:
		_preview_texture.texture = null
	_frame_label.text = "帧: %d / %d" % [_preview_frame + 1, total]
	if _preview_frame < _seq_list.item_count:
		_seq_list.deselect_all()
		_seq_list.select(_preview_frame)
		_seq_list.ensure_current_is_visible()


## =====================================================
## 外部接口
## =====================================================

func load_animation_data(anim: Resource) -> void:
	_current_anim = anim
	_refresh_all()

func get_current_animation() -> Resource:
	return _current_anim
