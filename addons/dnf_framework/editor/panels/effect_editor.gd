@tool
extends Control

## 效果/事件编辑器 — 编辑技能帧事件（DNFFrameEvent）

signal event_changed()

const FrameEvent = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")

var _current_skill: Resource  ## DNFSkillDataV2
var _events: Array = []  ## 当前编辑的事件列表（技能顶层 events）
var _selected_event_idx: int = -1

## UI 引用
var _event_list: ItemList
var _frame_spin: SpinBox
var _type_option: OptionButton
var _data_edit: TextEdit


func _ready() -> void:
	_build_ui()


## 设置当前技能，刷新事件列表
func set_skill(skill: Resource) -> void:
	_current_skill = skill
	_events = skill.events if skill else []
	_selected_event_idx = -1
	_refresh_event_list()
	_refresh_properties()


## 构建完整 UI
func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var main_h := HBoxContainer.new()
	main_h.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_h)

	## 左侧：事件列表
	var left_panel := VBoxContainer.new()
	left_panel.custom_minimum_size.x = 180
	main_h.add_child(left_panel)

	var list_label := Label.new()
	list_label.text = "事件列表"
	left_panel.add_child(list_label)

	_event_list = ItemList.new()
	_event_list.custom_minimum_size.y = 200
	_event_list.item_selected.connect(_on_event_list_selected)
	left_panel.add_child(_event_list)

	var btn_row := HBoxContainer.new()
	var btn_add := Button.new()
	btn_add.text = "添加事件"
	btn_add.pressed.connect(_on_add_event)
	btn_row.add_child(btn_add)

	var btn_del := Button.new()
	btn_del.text = "删除事件"
	btn_del.pressed.connect(_on_delete_event)
	btn_row.add_child(btn_del)

	left_panel.add_child(btn_row)

	## 右侧：事件属性
	var right_panel := VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_h.add_child(right_panel)

	var props_label := Label.new()
	props_label.text = "事件属性"
	right_panel.add_child(props_label)

	_frame_spin = SpinBox.new()
	_frame_spin.min_value = 0
	_frame_spin.max_value = 99999
	_frame_spin.value_changed.connect(_on_frame_changed)
	right_panel.add_child(_make_row("帧", _frame_spin))

	_type_option = OptionButton.new()
	_type_option.add_item("生成特效", FrameEvent.EventType.SPAWN_EFFECT)
	_type_option.add_item("播放音效", FrameEvent.EventType.PLAY_SOUND)
	_type_option.add_item("镜头震动", FrameEvent.EventType.CAMERA_SHAKE)
	_type_option.add_item("生成投射物", FrameEvent.EventType.SPAWN_PROJECTILE)
	_type_option.add_item("施加BUFF", FrameEvent.EventType.APPLY_BUFF)
	_type_option.add_item("开启霸体", FrameEvent.EventType.SUPER_ARMOR_START)
	_type_option.add_item("关闭霸体", FrameEvent.EventType.SUPER_ARMOR_END)
	_type_option.add_item("开启无敌", FrameEvent.EventType.INVINCIBLE_START)
	_type_option.add_item("关闭无敌", FrameEvent.EventType.INVINCIBLE_END)
	_type_option.add_item("开放取消窗口", FrameEvent.EventType.CANCEL_WINDOW_OPEN)
	_type_option.add_item("关闭取消窗口", FrameEvent.EventType.CANCEL_WINDOW_CLOSE)
	_type_option.add_item("自定义信号", FrameEvent.EventType.CUSTOM_SIGNAL)
	_type_option.item_selected.connect(_on_type_selected)
	right_panel.add_child(_make_row("类型", _type_option))

	var data_label := Label.new()
	data_label.text = "附加数据 (JSON)"
	right_panel.add_child(data_label)

	_data_edit = TextEdit.new()
	_data_edit.custom_minimum_size.y = 120
	_data_edit.text_changed.connect(_on_data_changed)
	right_panel.add_child(_data_edit)


func _make_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size.x = 60
	row.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _refresh_event_list() -> void:
	_event_list.clear()
	var type_names: Array[String] = [
		"生成特效", "播放音效", "镜头震动", "生成投射物", "施加BUFF",
		"开启霸体", "关闭霸体", "开启无敌", "关闭无敌",
		"开放取消窗口", "关闭取消窗口", "自定义信号"
	]
	for i in range(_events.size()):
		var ev = _events[i]
		var frame_val: int = ev.frame if ev else 0
		var type_val: int = ev.type if ev else int(FrameEvent.EventType.CUSTOM_SIGNAL)
		var type_str: String = type_names[type_val] if type_val < type_names.size() else "自定义"
		_event_list.add_item("帧 %d: %s" % [frame_val, type_str])


func _refresh_properties() -> void:
	if _selected_event_idx < 0 or _selected_event_idx >= _events.size():
		_frame_spin.value = 0
		_type_option.selected = _type_option.item_count - 1
		_data_edit.text = "{}"
		return

	var ev = _events[_selected_event_idx]
	_frame_spin.value = ev.frame
	_type_option.selected = _get_option_index_by_id(_type_option, ev.type)
	var data_dict: Dictionary = ev.data
	_data_edit.text = JSON.stringify(data_dict, "\t")


func _get_option_index_by_id(opt: OptionButton, id: int) -> int:
	for i in range(opt.item_count):
		if opt.get_item_id(i) == id:
			return i
	return 0


func _on_event_list_selected(idx: int) -> void:
	_selected_event_idx = idx
	_refresh_properties()


func _on_add_event() -> void:
	if _current_skill == null:
		return
	var ev := FrameEvent.new()
	ev.frame = 0
	ev.type = FrameEvent.EventType.CUSTOM_SIGNAL
	ev.data = {}
	_events.append(ev)
	_current_skill.set("events", _events)
	_refresh_event_list()
	_event_list.select(_events.size() - 1)
	_selected_event_idx = _events.size() - 1
	_refresh_properties()
	event_changed.emit()


func _on_delete_event() -> void:
	if _current_skill == null or _selected_event_idx < 0:
		return
	_events.remove_at(_selected_event_idx)
	_current_skill.set("events", _events)
	_selected_event_idx = -1
	_refresh_event_list()
	_refresh_properties()
	event_changed.emit()


func _on_frame_changed(val: float) -> void:
	if _selected_event_idx >= 0 and _selected_event_idx < _events.size():
		_events[_selected_event_idx].set("frame", int(val))
		_refresh_event_list()
		event_changed.emit()


func _on_type_selected(idx: int) -> void:
	if _selected_event_idx >= 0 and _selected_event_idx < _events.size():
		_events[_selected_event_idx].set("type", _type_option.get_item_id(idx))
		_refresh_event_list()
		event_changed.emit()


func _on_data_changed() -> void:
	if _selected_event_idx < 0 or _selected_event_idx >= _events.size():
		return
	var ev = _events[_selected_event_idx]
	var json := JSON.new()
	var err := json.parse(_data_edit.text)
	if err == OK:
		ev.set("data", json.get_data())
		event_changed.emit()
