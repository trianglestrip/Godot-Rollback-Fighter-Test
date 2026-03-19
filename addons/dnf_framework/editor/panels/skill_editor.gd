@tool
extends Control

## 技能编辑器面板 — 编辑 DNFSkillDataV2 资源

signal skill_selected(skill: Resource)
signal skill_saved(path: String)

const SkillDataV2 = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")

var _current_skill: Resource
var _character_data: Resource  ## 可选：从角色加载的技能列表
var _skill_list_items: Array = []  ## 技能资源列表

## UI 引用
var _skill_list: ItemList
var _skill_name_edit: LineEdit
var _display_name_edit: LineEdit
var _mp_cost_spin: SpinBox
var _hp_cost_spin: SpinBox
var _cooldown_spin: SpinBox
var _damage_type_option: OptionButton
var _element_option: OptionButton
var _skill_coefficient_spin: SpinBox
var _super_armor_option: OptionButton
var _cancelable_check: CheckBox
var _cancel_into_edit: LineEdit
var _ground_only_check: CheckBox
var _air_usable_check: CheckBox
var _priority_spin: SpinBox


func _ready() -> void:
	_build_ui()


## 构建完整 UI
func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var main_h := HBoxContainer.new()
	main_h.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_h)

	## 左侧边栏：技能列表
	var left_panel := VBoxContainer.new()
	left_panel.custom_minimum_size.x = 200
	main_h.add_child(left_panel)

	var list_label := Label.new()
	list_label.text = "技能列表"
	left_panel.add_child(list_label)

	_skill_list = ItemList.new()
	_skill_list.custom_minimum_size.y = 200
	_skill_list.item_selected.connect(_on_skill_list_selected)
	left_panel.add_child(_skill_list)

	var btn_row := HBoxContainer.new()
	left_panel.add_child(btn_row)

	var btn_new := Button.new()
	btn_new.text = "新建技能"
	btn_new.pressed.connect(_on_new_skill)
	btn_row.add_child(btn_new)

	var btn_delete := Button.new()
	btn_delete.text = "删除技能"
	btn_delete.pressed.connect(_on_delete_skill)
	btn_row.add_child(btn_delete)

	var btn_save := Button.new()
	btn_save.text = "保存"
	btn_save.pressed.connect(_on_save)
	btn_row.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "加载"
	btn_load.pressed.connect(_on_load)
	btn_row.add_child(btn_load)

	## 右侧：技能属性编辑
	var right_panel := ScrollContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_h.add_child(right_panel)

	var props_v := VBoxContainer.new()
	right_panel.add_child(props_v)

	## 基本信息
	var info_group := _make_group("基本信息")
	props_v.add_child(info_group)

	_skill_name_edit = LineEdit.new()
	_skill_name_edit.placeholder_text = "skill_name"
	_skill_name_edit.text_changed.connect(_on_skill_name_changed)
	info_group.add_child(_make_row("技能名", _skill_name_edit))

	_display_name_edit = LineEdit.new()
	_display_name_edit.placeholder_text = "显示名称"
	_display_name_edit.text_changed.connect(_on_display_name_changed)
	info_group.add_child(_make_row("显示名", _display_name_edit))

	## 消耗
	var cost_group := _make_group("消耗")
	props_v.add_child(cost_group)

	_mp_cost_spin = SpinBox.new()
	_mp_cost_spin.min_value = 0
	_mp_cost_spin.max_value = 99999
	_mp_cost_spin.value_changed.connect(_on_mp_cost_changed)
	cost_group.add_child(_make_row("MP消耗", _mp_cost_spin))

	_hp_cost_spin = SpinBox.new()
	_hp_cost_spin.min_value = 0
	_hp_cost_spin.max_value = 99999
	_hp_cost_spin.value_changed.connect(_on_hp_cost_changed)
	cost_group.add_child(_make_row("HP消耗", _hp_cost_spin))

	_cooldown_spin = SpinBox.new()
	_cooldown_spin.min_value = 0
	_cooldown_spin.max_value = 99999
	_cooldown_spin.value_changed.connect(_on_cooldown_changed)
	cost_group.add_child(_make_row("冷却帧数", _cooldown_spin))

	## 伤害属性
	var dmg_group := _make_group("伤害属性")
	props_v.add_child(dmg_group)

	_damage_type_option = OptionButton.new()
	_damage_type_option.add_item("物理百分比", SkillDataV2.DamageType.PHYSICAL_PERCENT)
	_damage_type_option.add_item("魔法百分比", SkillDataV2.DamageType.MAGICAL_PERCENT)
	_damage_type_option.add_item("独立", SkillDataV2.DamageType.INDEPENDENT)
	_damage_type_option.item_selected.connect(_on_damage_type_selected)
	dmg_group.add_child(_make_row("伤害类型", _damage_type_option))

	_element_option = OptionButton.new()
	_element_option.add_item("无", SkillDataV2.Element.NEUTRAL)
	_element_option.add_item("火", SkillDataV2.Element.FIRE)
	_element_option.add_item("冰", SkillDataV2.Element.ICE)
	_element_option.add_item("光", SkillDataV2.Element.LIGHT)
	_element_option.add_item("暗", SkillDataV2.Element.DARK)
	_element_option.item_selected.connect(_on_element_selected)
	dmg_group.add_child(_make_row("属性", _element_option))

	_skill_coefficient_spin = SpinBox.new()
	_skill_coefficient_spin.min_value = 0.0
	_skill_coefficient_spin.step = 0.01
	_skill_coefficient_spin.value_changed.connect(_on_skill_coefficient_changed)
	dmg_group.add_child(_make_row("技能系数", _skill_coefficient_spin))

	_super_armor_option = OptionButton.new()
	_super_armor_option.add_item("无", SkillDataV2.SuperArmorLevel.NONE)
	_super_armor_option.add_item("轻霸体", SkillDataV2.SuperArmorLevel.LIGHT)
	_super_armor_option.add_item("重霸体", SkillDataV2.SuperArmorLevel.HEAVY)
	_super_armor_option.add_item("完全霸体", SkillDataV2.SuperArmorLevel.FULL)
	_super_armor_option.item_selected.connect(_on_super_armor_selected)
	dmg_group.add_child(_make_row("霸体等级", _super_armor_option))

	## 取消系统
	var cancel_group := _make_group("取消系统")
	props_v.add_child(cancel_group)

	_cancelable_check = CheckBox.new()
	_cancelable_check.text = "可取消"
	_cancelable_check.toggled.connect(_on_cancelable_toggled)
	cancel_group.add_child(_cancelable_check)

	_cancel_into_edit = LineEdit.new()
	_cancel_into_edit.placeholder_text = "逗号分隔的技能名"
	_cancel_into_edit.text_changed.connect(_on_cancel_into_changed)
	cancel_group.add_child(_make_row("可取消到", _cancel_into_edit))

	## 使用条件
	var cond_group := _make_group("使用条件")
	props_v.add_child(cond_group)

	_ground_only_check = CheckBox.new()
	_ground_only_check.text = "仅地面可用"
	_ground_only_check.toggled.connect(_on_ground_only_toggled)
	cond_group.add_child(_ground_only_check)

	_air_usable_check = CheckBox.new()
	_air_usable_check.text = "空中可用"
	_air_usable_check.toggled.connect(_on_air_usable_toggled)
	cond_group.add_child(_air_usable_check)

	_priority_spin = SpinBox.new()
	_priority_spin.min_value = -999
	_priority_spin.max_value = 999
	_priority_spin.value_changed.connect(_on_priority_changed)
	cond_group.add_child(_make_row("优先级", _priority_spin))

	## 底部：Timeline 占位
	var bottom_area := VBoxContainer.new()
	props_v.add_child(bottom_area)

	var timeline_label := Label.new()
	timeline_label.text = "Timeline 编辑器将在此集成"
	timeline_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	bottom_area.add_child(timeline_label)


func _make_group(title: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 14)
	v.add_child(lbl)
	return v


func _make_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size.x = 100
	row.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


## 加载技能到编辑器
func load_skill(skill: Resource) -> void:
	_current_skill = skill
	_refresh_properties()


## 保存技能到路径
func save_skill(path: String) -> void:
	if _current_skill == null:
		return
	var err := ResourceSaver.save(_current_skill, path)
	if err == OK:
		skill_saved.emit(path)


## 从角色数据或独立文件加载技能列表
func load_skills_from_character(char_data: Resource) -> void:
	_character_data = char_data
	_skill_list_items.clear()
	if char_data and char_data.get("skills"):
		for s in char_data.skills:
			_skill_list_items.append(s)
	_refresh_skill_list()


## 从独立技能文件路径加载
func load_skills_from_paths(paths: Array) -> void:
	_character_data = null
	_skill_list_items.clear()
	for p in paths:
		var res := ResourceLoader.load(p) as Resource
		if res:
			_skill_list_items.append(res)
	_refresh_skill_list()


func _refresh_skill_list() -> void:
	_skill_list.clear()
	for i in range(_skill_list_items.size()):
		var s = _skill_list_items[i]
		var name_str: String = s.skill_name if s else ""
		if name_str.is_empty():
			name_str = "未命名技能 %d" % (i + 1)
		_skill_list.add_item(name_str)


func _refresh_properties() -> void:
	if _current_skill == null:
		_skill_name_edit.text = ""
		_display_name_edit.text = ""
		_mp_cost_spin.value = 0
		_hp_cost_spin.value = 0
		_cooldown_spin.value = 0
		_damage_type_option.selected = 0
		_element_option.selected = 0
		_skill_coefficient_spin.value = 1.0
		_super_armor_option.selected = 0
		_cancelable_check.button_pressed = false
		_cancel_into_edit.text = ""
		_ground_only_check.button_pressed = true
		_air_usable_check.button_pressed = false
		_priority_spin.value = 0
		return

	_skill_name_edit.text = _current_skill.skill_name
	_display_name_edit.text = _current_skill.display_name
	_mp_cost_spin.value = _current_skill.mp_cost
	_hp_cost_spin.value = _current_skill.hp_cost
	_cooldown_spin.value = _current_skill.cooldown_frames
	_damage_type_option.selected = _current_skill.damage_type
	_element_option.selected = _current_skill.element
	_skill_coefficient_spin.value = _current_skill.skill_coefficient
	_super_armor_option.selected = _current_skill.super_armor_level
	_cancelable_check.button_pressed = _current_skill.cancelable
	var cancel_arr: Array = _current_skill.cancel_into
	_cancel_into_edit.text = ", ".join(cancel_arr)
	_ground_only_check.button_pressed = _current_skill.ground_only
	_air_usable_check.button_pressed = _current_skill.air_usable
	_priority_spin.value = _current_skill.priority


func _on_skill_list_selected(idx: int) -> void:
	if idx < 0 or idx >= _skill_list_items.size():
		return
	var skill = _skill_list_items[idx]
	_current_skill = skill
	_refresh_properties()
	skill_selected.emit(skill)


func _on_new_skill() -> void:
	var skill := SkillDataV2.new()
	skill.skill_name = "new_skill_%d" % _skill_list_items.size()
	_skill_list_items.append(skill)
	_refresh_skill_list()
	_current_skill = skill
	_refresh_properties()
	skill_selected.emit(skill)


func _on_delete_skill() -> void:
	if _current_skill == null:
		return
	var idx := _skill_list_items.find(_current_skill)
	if idx >= 0:
		_skill_list_items.remove_at(idx)
		if _character_data and _character_data.get("skills"):
			var skills_arr: Array = _character_data.skills
			var skill_idx := skills_arr.find(_current_skill)
			if skill_idx >= 0:
				skills_arr.remove_at(skill_idx)
		_current_skill = _skill_list_items[0] if _skill_list_items.size() > 0 else null
		_refresh_skill_list()
		_refresh_properties()
		if _current_skill:
			skill_selected.emit(_current_skill)


func _on_save() -> void:
	if _current_skill == null:
		return
	var path := _current_skill.resource_path
	if path.is_empty():
		path = "res://new_skill.tres"
	save_skill(path)


func _on_load() -> void:
	# 使用 EditorFileDialog 需在 EditorPlugin 中处理，此处仅占位
	# 实际项目中可 emit 信号让主编辑器打开文件对话框
	pass


func _on_skill_name_changed(new_text: String) -> void:
	if _current_skill:
		_current_skill.set("skill_name", new_text)


func _on_display_name_changed(new_text: String) -> void:
	if _current_skill:
		_current_skill.set("display_name", new_text)


func _on_mp_cost_changed(val: float) -> void:
	if _current_skill:
		_current_skill.set("mp_cost", int(val))


func _on_hp_cost_changed(val: float) -> void:
	if _current_skill:
		_current_skill.set("hp_cost", int(val))


func _on_cooldown_changed(val: float) -> void:
	if _current_skill:
		_current_skill.set("cooldown_frames", int(val))


func _on_damage_type_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.set("damage_type", _damage_type_option.get_item_id(idx))


func _on_element_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.set("element", _element_option.get_item_id(idx))


func _on_skill_coefficient_changed(val: float) -> void:
	if _current_skill:
		_current_skill.set("skill_coefficient", val)


func _on_super_armor_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.set("super_armor_level", _super_armor_option.get_item_id(idx))


func _on_cancelable_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.set("cancelable", pressed)


func _on_cancel_into_changed(new_text: String) -> void:
	if _current_skill:
		var arr: Array[String] = []
		for s in new_text.split(","):
			var t := s.strip_edges()
			if not t.is_empty():
				arr.append(t)
		_current_skill.set("cancel_into", arr)


func _on_ground_only_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.set("ground_only", pressed)


func _on_air_usable_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.set("air_usable", pressed)


func _on_priority_changed(val: float) -> void:
	if _current_skill:
		_current_skill.set("priority", int(val))
