@tool
extends Control

## 技能编辑器面板 — 集成 Timeline + Preview + Inspector
## 布局：左侧技能列表 | 中间 Preview+Timeline | 右侧 Inspector

signal skill_selected(skill: Resource)
signal skill_saved(path: String)

const SkillDataRes = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const FrameEventRes = preload("res://addons/dnf_framework/resources/skill/frame_event.gd")
const AttackPhaseRes = preload("res://addons/dnf_framework/resources/skill/attack_phase.gd")
const MovementPhaseRes = preload("res://addons/dnf_framework/resources/skill/movement_phase.gd")
const HitboxDataRes = preload("res://addons/dnf_framework/resources/combat/hitbox_data.gd")
const HitBehaviorRes = preload("res://addons/dnf_framework/runtime/combat/hit_behavior.gd")

var _current_skill: Resource
var _character_data: Resource
var _skill_list_items: Array = []

## 左侧面板
var _skill_list: ItemList
var _skill_name_edit: LineEdit
var _display_name_edit: LineEdit

## 中间面板
var _preview_container: Control
var _sprite_preview: Control
var _hitbox_preview: Control
var _timeline: Control

## 右侧面板 — Inspector
var _inspector_scroll: ScrollContainer
var _inspector_container: VBoxContainer
var _inspector_title: Label

## 技能基础属性控件
var _icon_preview: TextureRect
var _icon_btn: Button
var _anim_bind_label: Label
var _anim_bind_btn: Button
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

## Inspector 动态面板（选中 Phase/Event/Movement 时替换）
var _dynamic_inspector: VBoxContainer

## 当前选中的轨道元素
var _selected_type: String = ""
var _selected_resource: Resource
var _selected_index: int = -1


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var root := HSplitContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.split_offset = 180
	add_child(root)

	_build_left_panel(root)

	var center_right := HSplitContainer.new()
	center_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_right.split_offset = -280
	root.add_child(center_right)

	_build_center_panel(center_right)
	_build_right_panel(center_right)


## ==================== 左侧：技能列表 ====================
func _build_left_panel(parent: Control) -> void:
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 180
	parent.add_child(left)

	var header := Label.new()
	header.text = "技能列表"
	header.add_theme_font_size_override("font_size", 14)
	left.add_child(header)

	_skill_list = ItemList.new()
	_skill_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_skill_list.item_selected.connect(_on_skill_list_selected)
	left.add_child(_skill_list)

	var name_row := HBoxContainer.new()
	left.add_child(name_row)
	_skill_name_edit = LineEdit.new()
	_skill_name_edit.placeholder_text = "技能名..."
	_skill_name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_skill_name_edit.text_changed.connect(_on_skill_name_changed)
	name_row.add_child(_skill_name_edit)

	var btn_row := HBoxContainer.new()
	left.add_child(btn_row)

	var btn_new := Button.new()
	btn_new.text = "+"
	btn_new.tooltip_text = "新建技能"
	btn_new.pressed.connect(_on_new_skill)
	btn_row.add_child(btn_new)

	var btn_del := Button.new()
	btn_del.text = "-"
	btn_del.tooltip_text = "删除技能"
	btn_del.pressed.connect(_on_delete_skill)
	btn_row.add_child(btn_del)

	var btn_save := Button.new()
	btn_save.text = "保存"
	btn_save.pressed.connect(_on_save)
	btn_row.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "加载"
	btn_load.pressed.connect(_on_load)
	btn_row.add_child(btn_load)


## ==================== 中间：Preview + Timeline ====================
func _build_center_panel(parent: Control) -> void:
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(center)

	_preview_container = PanelContainer.new()
	_preview_container.custom_minimum_size.y = 200
	center.add_child(_preview_container)

	var preview_stack := Control.new()
	preview_stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	_preview_container.add_child(preview_stack)

	var sprite_script := load("res://addons/dnf_framework/editor/preview/sprite_preview.gd") as GDScript
	if sprite_script:
		_sprite_preview = Control.new()
		_sprite_preview.set_script(sprite_script)
		_sprite_preview.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview_stack.add_child(_sprite_preview)

	var hitbox_script := load("res://addons/dnf_framework/editor/preview/hitbox_preview.gd") as GDScript
	if hitbox_script:
		_hitbox_preview = Control.new()
		_hitbox_preview.set_script(hitbox_script)
		_hitbox_preview.set_anchors_preset(Control.PRESET_FULL_RECT)
		preview_stack.add_child(_hitbox_preview)

	center.add_child(HSeparator.new())

	var timeline_script := load("res://addons/dnf_framework/editor/timeline/timeline_root.gd") as GDScript
	if timeline_script:
		_timeline = Control.new()
		_timeline.set_script(timeline_script)
		_timeline.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_timeline.custom_minimum_size.y = 160
		_timeline.frame_changed.connect(_on_timeline_frame_changed)
		_timeline.phase_selected.connect(_on_track_phase_selected)
		_timeline.event_selected.connect(_on_track_event_selected)
		_timeline.movement_selected.connect(_on_track_movement_selected)
		center.add_child(_timeline)


## ==================== 右侧：Inspector ====================
func _build_right_panel(parent: Control) -> void:
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 280
	parent.add_child(right)

	_inspector_title = Label.new()
	_inspector_title.text = "属性"
	_inspector_title.add_theme_font_size_override("font_size", 14)
	right.add_child(_inspector_title)

	_inspector_scroll = ScrollContainer.new()
	_inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inspector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(_inspector_scroll)

	_inspector_container = VBoxContainer.new()
	_inspector_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_inspector_scroll.add_child(_inspector_container)

	_build_skill_properties()


func _build_skill_properties() -> void:
	for c in _inspector_container.get_children():
		c.queue_free()
	_dynamic_inspector = null

	## 图标 + 动画绑定
	var bind_group := _make_group("绑定")
	_inspector_container.add_child(bind_group)

	var icon_row := HBoxContainer.new()
	bind_group.add_child(icon_row)
	_icon_preview = TextureRect.new()
	_icon_preview.custom_minimum_size = Vector2(48, 48)
	_icon_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_row.add_child(_icon_preview)
	var icon_v := VBoxContainer.new()
	icon_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon_row.add_child(icon_v)
	_icon_btn = Button.new()
	_icon_btn.text = "选择图标..."
	_icon_btn.pressed.connect(_on_pick_icon)
	icon_v.add_child(_icon_btn)

	var anim_row := HBoxContainer.new()
	bind_group.add_child(anim_row)
	var anim_label := Label.new()
	anim_label.text = "动画:"
	anim_label.custom_minimum_size.x = 50
	anim_row.add_child(anim_label)
	_anim_bind_label = Label.new()
	_anim_bind_label.text = "(未绑定)"
	_anim_bind_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_anim_bind_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	anim_row.add_child(_anim_bind_label)
	_anim_bind_btn = Button.new()
	_anim_bind_btn.text = "绑定..."
	_anim_bind_btn.pressed.connect(_on_pick_animation)
	anim_row.add_child(_anim_bind_btn)

	## 显示名
	_display_name_edit = LineEdit.new()
	_display_name_edit.placeholder_text = "显示名称"
	_display_name_edit.text_changed.connect(_on_display_name_changed)
	bind_group.add_child(_make_row("显示名", _display_name_edit))

	## 消耗
	var cost_group := _make_group("消耗与冷却")
	_inspector_container.add_child(cost_group)

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
	cost_group.add_child(_make_row("冷却帧", _cooldown_spin))

	## 伤害
	var dmg_group := _make_group("伤害属性")
	_inspector_container.add_child(dmg_group)

	_damage_type_option = OptionButton.new()
	_damage_type_option.add_item("物理百分比", SkillDataRes.DamageType.PHYSICAL_PERCENT)
	_damage_type_option.add_item("魔法百分比", SkillDataRes.DamageType.MAGICAL_PERCENT)
	_damage_type_option.add_item("独立", SkillDataRes.DamageType.INDEPENDENT)
	_damage_type_option.item_selected.connect(_on_damage_type_selected)
	dmg_group.add_child(_make_row("伤害类型", _damage_type_option))

	_element_option = OptionButton.new()
	_element_option.add_item("无", SkillDataRes.Element.NEUTRAL)
	_element_option.add_item("火", SkillDataRes.Element.FIRE)
	_element_option.add_item("冰", SkillDataRes.Element.ICE)
	_element_option.add_item("光", SkillDataRes.Element.LIGHT)
	_element_option.add_item("暗", SkillDataRes.Element.DARK)
	_element_option.item_selected.connect(_on_element_selected)
	dmg_group.add_child(_make_row("属性", _element_option))

	_skill_coefficient_spin = SpinBox.new()
	_skill_coefficient_spin.min_value = 0.0
	_skill_coefficient_spin.max_value = 100.0
	_skill_coefficient_spin.step = 0.01
	_skill_coefficient_spin.value_changed.connect(_on_skill_coefficient_changed)
	dmg_group.add_child(_make_row("技能系数", _skill_coefficient_spin))

	_super_armor_option = OptionButton.new()
	_super_armor_option.add_item("无", SkillDataRes.SuperArmorLevel.NONE)
	_super_armor_option.add_item("轻霸体", SkillDataRes.SuperArmorLevel.LIGHT)
	_super_armor_option.add_item("重霸体", SkillDataRes.SuperArmorLevel.HEAVY)
	_super_armor_option.add_item("完全霸体", SkillDataRes.SuperArmorLevel.FULL)
	_super_armor_option.item_selected.connect(_on_super_armor_selected)
	dmg_group.add_child(_make_row("霸体等级", _super_armor_option))

	## 取消系统
	var cancel_group := _make_group("取消系统")
	_inspector_container.add_child(cancel_group)

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
	_inspector_container.add_child(cond_group)

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

	## 动态 Inspector 容器（选中轨道元素时显示）
	_inspector_container.add_child(HSeparator.new())
	_dynamic_inspector = VBoxContainer.new()
	_inspector_container.add_child(_dynamic_inspector)


## ==================== 工具函数 ====================
func _make_group(title: String) -> VBoxContainer:
	var v := VBoxContainer.new()
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	v.add_child(lbl)
	return v


func _make_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size.x = 80
	row.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


## ==================== 数据加载 ====================
func load_skill(skill: Resource) -> void:
	_current_skill = skill
	_refresh_properties()
	_sync_timeline()
	_sync_preview()


func save_skill(path: String) -> void:
	if _current_skill == null:
		return
	var err := ResourceSaver.save(_current_skill, path)
	if err == OK:
		skill_saved.emit(path)


func load_skills_from_character(char_data: Resource) -> void:
	_character_data = char_data
	_skill_list_items.clear()
	if char_data and char_data.get("skills"):
		for s in char_data.skills:
			_skill_list_items.append(s)
	_refresh_skill_list()


func load_skills_from_paths(paths: Array) -> void:
	_character_data = null
	_skill_list_items.clear()
	for p in paths:
		var res := ResourceLoader.load(p) as Resource
		if res:
			_skill_list_items.append(res)
	_refresh_skill_list()


## ==================== UI 刷新 ====================
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
		_icon_preview.texture = null
		_anim_bind_label.text = "(未绑定)"
		_anim_bind_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		_clear_dynamic_inspector()
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

	var ui_data: Resource = _current_skill.ui if "ui" in _current_skill else null
	if ui_data and "icon" in ui_data:
		_icon_preview.texture = ui_data.icon
	else:
		_icon_preview.texture = null

	var anim_name: String = _current_skill.animation_name if "animation_name" in _current_skill else ""
	if not anim_name.is_empty():
		_anim_bind_label.text = anim_name
		_anim_bind_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	else:
		_anim_bind_label.text = "(未绑定)"
		_anim_bind_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))

	_clear_dynamic_inspector()


func _sync_timeline() -> void:
	if _timeline and _timeline.has_method("set_skill_data"):
		_timeline.set_skill_data(_current_skill)


func _sync_preview() -> void:
	if not _current_skill:
		if _sprite_preview:
			_sprite_preview.sprite_frames = null
			_sprite_preview.animation_name = ""
		if _hitbox_preview:
			_hitbox_preview.skill_data = null
		return

	if _sprite_preview:
		_sprite_preview.animation_name = _current_skill.animation_name if "animation_name" in _current_skill else ""
		_sprite_preview.current_frame = 0
	if _hitbox_preview:
		_hitbox_preview.skill_data = _current_skill
		_hitbox_preview.current_frame = 0


## ==================== Timeline 联动 ====================
func _on_timeline_frame_changed(frame: int) -> void:
	if _sprite_preview:
		_sprite_preview.current_frame = frame
	if _hitbox_preview:
		_hitbox_preview.current_frame = frame


func _on_track_phase_selected(idx: int) -> void:
	if not _current_skill or idx < 0 or idx >= _current_skill.phases.size():
		return
	_selected_type = "phase"
	_selected_resource = _current_skill.phases[idx]
	_selected_index = idx
	_show_phase_inspector(_selected_resource)


func _on_track_event_selected(idx: int) -> void:
	var all_events := _gather_all_events()
	if idx < 0 or idx >= all_events.size():
		return
	_selected_type = "event"
	_selected_resource = all_events[idx]
	_selected_index = idx
	_show_event_inspector(_selected_resource)


func _on_track_movement_selected(idx: int) -> void:
	if not _current_skill or idx < 0 or idx >= _current_skill.movement.size():
		return
	_selected_type = "movement"
	_selected_resource = _current_skill.movement[idx]
	_selected_index = idx
	_show_movement_inspector(_selected_resource)


func _gather_all_events() -> Array:
	if not _current_skill:
		return []
	var result: Array = []
	result.append_array(_current_skill.events)
	for p in _current_skill.phases:
		if p and not p.events.is_empty():
			result.append_array(p.events)
	return result


## ==================== Inspector 动态面板 ====================
func _clear_dynamic_inspector() -> void:
	if _dynamic_inspector:
		for c in _dynamic_inspector.get_children():
			c.queue_free()
	_selected_type = ""
	_selected_resource = null
	_selected_index = -1


func _show_phase_inspector(phase: Resource) -> void:
	_clear_dynamic_inspector()
	if not phase:
		return

	var title := Label.new()
	title.text = "攻击区间 #%d" % _selected_index
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(1.0, 0.6, 0.3))
	_dynamic_inspector.add_child(title)

	var start_spin := SpinBox.new()
	start_spin.min_value = 0
	start_spin.max_value = 9999
	start_spin.value = phase.start_frame
	start_spin.value_changed.connect(func(v: float) -> void:
		phase.start_frame = int(v)
		_sync_timeline()
	)
	_dynamic_inspector.add_child(_make_row("开始帧", start_spin))

	var end_spin := SpinBox.new()
	end_spin.min_value = 0
	end_spin.max_value = 9999
	end_spin.value = phase.end_frame
	end_spin.value_changed.connect(func(v: float) -> void:
		phase.end_frame = int(v)
		_sync_timeline()
	)
	_dynamic_inspector.add_child(_make_row("结束帧", end_spin))

	## Hitbox
	_dynamic_inspector.add_child(HSeparator.new())
	var hb_label := Label.new()
	hb_label.text = "碰撞体"
	hb_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	_dynamic_inspector.add_child(hb_label)

	if not phase.hitbox:
		phase.hitbox = HitboxDataRes.new()

	var hitbox: Resource = phase.hitbox
	var shape_w := SpinBox.new()
	shape_w.min_value = 1
	shape_w.max_value = 9999
	shape_w.value = hitbox.shape_size.x
	shape_w.value_changed.connect(func(v: float) -> void:
		hitbox.shape_size.x = v
		if _hitbox_preview:
			_hitbox_preview.queue_redraw()
	)
	_dynamic_inspector.add_child(_make_row("宽", shape_w))

	var shape_h := SpinBox.new()
	shape_h.min_value = 1
	shape_h.max_value = 9999
	shape_h.value = hitbox.shape_size.y
	shape_h.value_changed.connect(func(v: float) -> void:
		hitbox.shape_size.y = v
		if _hitbox_preview:
			_hitbox_preview.queue_redraw()
	)
	_dynamic_inspector.add_child(_make_row("高", shape_h))

	var off_x := SpinBox.new()
	off_x.min_value = -9999
	off_x.max_value = 9999
	off_x.value = hitbox.offset.x
	off_x.value_changed.connect(func(v: float) -> void:
		hitbox.offset.x = v
		if _hitbox_preview:
			_hitbox_preview.queue_redraw()
	)
	_dynamic_inspector.add_child(_make_row("偏移X", off_x))

	var off_y := SpinBox.new()
	off_y.min_value = -9999
	off_y.max_value = 9999
	off_y.value = hitbox.offset.y
	off_y.value_changed.connect(func(v: float) -> void:
		hitbox.offset.y = v
		if _hitbox_preview:
			_hitbox_preview.queue_redraw()
	)
	_dynamic_inspector.add_child(_make_row("偏移Y", off_y))

	var level_opt := OptionButton.new()
	level_opt.add_item("中段", HitboxDataRes.HitLevel.MID)
	level_opt.add_item("下段", HitboxDataRes.HitLevel.LOW)
	level_opt.add_item("上段", HitboxDataRes.HitLevel.OVERHEAD)
	level_opt.add_item("不可防", HitboxDataRes.HitLevel.UNBLOCKABLE)
	level_opt.selected = hitbox.hit_level
	level_opt.item_selected.connect(func(idx: int) -> void:
		hitbox.hit_level = level_opt.get_item_id(idx)
	)
	_dynamic_inspector.add_child(_make_row("判定高度", level_opt))

	## Hit Behavior
	_dynamic_inspector.add_child(HSeparator.new())
	var bhv_label := Label.new()
	bhv_label.text = "受击行为"
	bhv_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	_dynamic_inspector.add_child(bhv_label)

	if not phase.hit_behavior:
		phase.hit_behavior = HitBehaviorRes.new()

	var bhv: Resource = phase.hit_behavior
	var dmg_spin := SpinBox.new()
	dmg_spin.min_value = 0
	dmg_spin.max_value = 99999
	dmg_spin.value = bhv.damage
	dmg_spin.value_changed.connect(func(v: float) -> void:
		bhv.damage = int(v)
	)
	_dynamic_inspector.add_child(_make_row("伤害", dmg_spin))

	var hit_type_opt := OptionButton.new()
	hit_type_opt.add_item("普通", HitBehaviorRes.HitType.NORMAL)
	hit_type_opt.add_item("击退", HitBehaviorRes.HitType.KNOCK_BACK)
	hit_type_opt.add_item("击倒", HitBehaviorRes.HitType.KNOCK_DOWN)
	hit_type_opt.add_item("浮空", HitBehaviorRes.HitType.LAUNCH)
	for i in hit_type_opt.get_item_count():
		if hit_type_opt.get_item_id(i) == bhv.hit_type:
			hit_type_opt.selected = i
			break
	hit_type_opt.item_selected.connect(func(idx: int) -> void:
		bhv.hit_type = hit_type_opt.get_item_id(idx)
	)
	_dynamic_inspector.add_child(_make_row("受击类型", hit_type_opt))

	var stun_spin := SpinBox.new()
	stun_spin.min_value = 0
	stun_spin.max_value = 999
	stun_spin.value = bhv.hitstun_frames
	stun_spin.value_changed.connect(func(v: float) -> void:
		bhv.hitstun_frames = int(v)
	)
	_dynamic_inspector.add_child(_make_row("硬直帧", stun_spin))

	var hitstop_spin := SpinBox.new()
	hitstop_spin.min_value = 0
	hitstop_spin.max_value = 99
	hitstop_spin.value = bhv.hitstop_frames
	hitstop_spin.value_changed.connect(func(v: float) -> void:
		bhv.hitstop_frames = int(v)
	)
	_dynamic_inspector.add_child(_make_row("顿帧", hitstop_spin))

	var kb_force := SpinBox.new()
	kb_force.min_value = -999
	kb_force.max_value = 999
	kb_force.step = 0.1
	kb_force.value = bhv.knockback_force
	kb_force.value_changed.connect(func(v: float) -> void:
		bhv.knockback_force = v
	)
	_dynamic_inspector.add_child(_make_row("击退力", kb_force))

	var launch_force := SpinBox.new()
	launch_force.min_value = -999
	launch_force.max_value = 999
	launch_force.step = 0.1
	launch_force.value = bhv.launch_force
	launch_force.value_changed.connect(func(v: float) -> void:
		bhv.launch_force = v
	)
	_dynamic_inspector.add_child(_make_row("浮空力", launch_force))

	var self_kb := SpinBox.new()
	self_kb.min_value = -999
	self_kb.max_value = 999
	self_kb.step = 0.1
	self_kb.value = bhv.self_knockback
	self_kb.value_changed.connect(func(v: float) -> void:
		bhv.self_knockback = v
	)
	_dynamic_inspector.add_child(_make_row("自身后退", self_kb))

	var del_btn := Button.new()
	del_btn.text = "删除此区间"
	del_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	del_btn.pressed.connect(func() -> void:
		if _current_skill and _selected_index >= 0 and _selected_index < _current_skill.phases.size():
			_current_skill.phases.remove_at(_selected_index)
			_clear_dynamic_inspector()
			_sync_timeline()
	)
	_dynamic_inspector.add_child(del_btn)


func _show_event_inspector(ev: Resource) -> void:
	_clear_dynamic_inspector()
	_selected_type = "event"
	_selected_resource = ev
	if not ev:
		return

	var title := Label.new()
	title.text = "帧事件"
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.3))
	_dynamic_inspector.add_child(title)

	var frame_spin := SpinBox.new()
	frame_spin.min_value = 0
	frame_spin.max_value = 9999
	frame_spin.value = ev.frame
	frame_spin.value_changed.connect(func(v: float) -> void:
		ev.frame = int(v)
		_sync_timeline()
	)
	_dynamic_inspector.add_child(_make_row("触发帧", frame_spin))

	var type_opt := OptionButton.new()
	type_opt.add_item("生成特效", FrameEventRes.EventType.SPAWN_EFFECT)
	type_opt.add_item("播放音效", FrameEventRes.EventType.PLAY_SOUND)
	type_opt.add_item("镜头震动", FrameEventRes.EventType.CAMERA_SHAKE)
	type_opt.add_item("生成弹幕", FrameEventRes.EventType.SPAWN_PROJECTILE)
	type_opt.add_item("施加BUFF", FrameEventRes.EventType.APPLY_BUFF)
	type_opt.add_item("霸体开始", FrameEventRes.EventType.SUPER_ARMOR_START)
	type_opt.add_item("霸体结束", FrameEventRes.EventType.SUPER_ARMOR_END)
	type_opt.add_item("无敌开始", FrameEventRes.EventType.INVINCIBLE_START)
	type_opt.add_item("无敌结束", FrameEventRes.EventType.INVINCIBLE_END)
	type_opt.add_item("取消窗口开", FrameEventRes.EventType.CANCEL_WINDOW_OPEN)
	type_opt.add_item("取消窗口关", FrameEventRes.EventType.CANCEL_WINDOW_CLOSE)
	type_opt.add_item("自定义信号", FrameEventRes.EventType.CUSTOM_SIGNAL)
	for i in type_opt.get_item_count():
		if type_opt.get_item_id(i) == ev.type:
			type_opt.selected = i
			break
	type_opt.item_selected.connect(func(idx: int) -> void:
		ev.type = type_opt.get_item_id(idx)
		_show_event_data_fields(ev)
	)
	_dynamic_inspector.add_child(_make_row("事件类型", type_opt))

	_show_event_data_fields(ev)

	var del_btn := Button.new()
	del_btn.text = "删除此事件"
	del_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	del_btn.pressed.connect(func() -> void:
		if _current_skill:
			var idx: int = _current_skill.events.find(ev)
			if idx >= 0:
				_current_skill.events.remove_at(idx)
			else:
				for p in _current_skill.phases:
					var pidx: int = p.events.find(ev)
					if pidx >= 0:
						p.events.remove_at(pidx)
						break
			_clear_dynamic_inspector()
			_sync_timeline()
	)
	_dynamic_inspector.add_child(del_btn)


func _show_event_data_fields(ev: Resource) -> void:
	var data_container_name := "_event_data_fields"
	for c in _dynamic_inspector.get_children():
		if c.name == data_container_name:
			c.queue_free()
			break

	var data_v := VBoxContainer.new()
	data_v.name = data_container_name
	var insert_idx := _dynamic_inspector.get_child_count()
	if insert_idx > 0:
		insert_idx -= 1
	_dynamic_inspector.add_child(data_v)
	_dynamic_inspector.move_child(data_v, insert_idx)

	match ev.type:
		FrameEventRes.EventType.SPAWN_EFFECT:
			var path_edit := LineEdit.new()
			path_edit.placeholder_text = "res://effects/..."
			path_edit.text = ev.data.get("scene_path", "")
			path_edit.text_changed.connect(func(t: String) -> void:
				ev.data["scene_path"] = t
			)
			data_v.add_child(_make_row("特效路径", path_edit))
			var offset_x := SpinBox.new()
			offset_x.min_value = -9999
			offset_x.max_value = 9999
			offset_x.value = ev.data.get("offset_x", 0)
			offset_x.value_changed.connect(func(v: float) -> void:
				ev.data["offset_x"] = v
			)
			data_v.add_child(_make_row("偏移X", offset_x))
			var offset_y := SpinBox.new()
			offset_y.min_value = -9999
			offset_y.max_value = 9999
			offset_y.value = ev.data.get("offset_y", 0)
			offset_y.value_changed.connect(func(v: float) -> void:
				ev.data["offset_y"] = v
			)
			data_v.add_child(_make_row("偏移Y", offset_y))
		FrameEventRes.EventType.PLAY_SOUND:
			var path_edit := LineEdit.new()
			path_edit.placeholder_text = "res://audio/..."
			path_edit.text = ev.data.get("audio_path", "")
			path_edit.text_changed.connect(func(t: String) -> void:
				ev.data["audio_path"] = t
			)
			data_v.add_child(_make_row("音效路径", path_edit))
			var vol_spin := SpinBox.new()
			vol_spin.min_value = -80
			vol_spin.max_value = 24
			vol_spin.value = ev.data.get("volume_db", 0)
			vol_spin.value_changed.connect(func(v: float) -> void:
				ev.data["volume_db"] = v
			)
			data_v.add_child(_make_row("音量dB", vol_spin))
		FrameEventRes.EventType.CAMERA_SHAKE:
			var strength := SpinBox.new()
			strength.min_value = 0
			strength.max_value = 100
			strength.step = 0.1
			strength.value = ev.data.get("strength", 5.0)
			strength.value_changed.connect(func(v: float) -> void:
				ev.data["strength"] = v
			)
			data_v.add_child(_make_row("强度", strength))
			var dur := SpinBox.new()
			dur.min_value = 0
			dur.max_value = 60
			dur.value = ev.data.get("duration_frames", 6)
			dur.value_changed.connect(func(v: float) -> void:
				ev.data["duration_frames"] = int(v)
			)
			data_v.add_child(_make_row("持续帧", dur))
		FrameEventRes.EventType.SPAWN_PROJECTILE:
			var path_edit := LineEdit.new()
			path_edit.placeholder_text = "res://projectiles/..."
			path_edit.text = ev.data.get("scene_path", "")
			path_edit.text_changed.connect(func(t: String) -> void:
				ev.data["scene_path"] = t
			)
			data_v.add_child(_make_row("弹幕路径", path_edit))
		FrameEventRes.EventType.CUSTOM_SIGNAL:
			var sig_edit := LineEdit.new()
			sig_edit.placeholder_text = "signal_name"
			sig_edit.text = ev.data.get("signal_name", "")
			sig_edit.text_changed.connect(func(t: String) -> void:
				ev.data["signal_name"] = t
			)
			data_v.add_child(_make_row("信号名", sig_edit))
		_:
			var hint := Label.new()
			hint.text = "此事件类型无额外参数"
			hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
			data_v.add_child(hint)


func _show_movement_inspector(mov: Resource) -> void:
	_clear_dynamic_inspector()
	_selected_type = "movement"
	_selected_resource = mov
	if not mov:
		return

	var title := Label.new()
	title.text = "位移区间 #%d" % _selected_index
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(0.3, 0.5, 0.9))
	_dynamic_inspector.add_child(title)

	var start_spin := SpinBox.new()
	start_spin.min_value = 0
	start_spin.max_value = 9999
	start_spin.value = mov.start_frame
	start_spin.value_changed.connect(func(v: float) -> void:
		mov.start_frame = int(v)
		_sync_timeline()
	)
	_dynamic_inspector.add_child(_make_row("开始帧", start_spin))

	var end_spin := SpinBox.new()
	end_spin.min_value = 0
	end_spin.max_value = 9999
	end_spin.value = mov.end_frame
	end_spin.value_changed.connect(func(v: float) -> void:
		mov.end_frame = int(v)
		_sync_timeline()
	)
	_dynamic_inspector.add_child(_make_row("结束帧", end_spin))

	var vel_x := SpinBox.new()
	vel_x.min_value = -9999
	vel_x.max_value = 9999
	vel_x.value = mov.velocity.x
	vel_x.value_changed.connect(func(v: float) -> void:
		mov.velocity.x = v
	)
	_dynamic_inspector.add_child(_make_row("速度X", vel_x))

	var vel_y := SpinBox.new()
	vel_y.min_value = -9999
	vel_y.max_value = 9999
	vel_y.value = mov.velocity.y
	vel_y.value_changed.connect(func(v: float) -> void:
		mov.velocity.y = v
	)
	_dynamic_inspector.add_child(_make_row("速度Y", vel_y))

	var facing_check := CheckBox.new()
	facing_check.text = "相对朝向"
	facing_check.button_pressed = mov.relative_to_facing
	facing_check.toggled.connect(func(pressed: bool) -> void:
		mov.relative_to_facing = pressed
	)
	_dynamic_inspector.add_child(facing_check)

	var del_btn := Button.new()
	del_btn.text = "删除此位移"
	del_btn.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	del_btn.pressed.connect(func() -> void:
		if _current_skill and _selected_index >= 0 and _selected_index < _current_skill.movement.size():
			_current_skill.movement.remove_at(_selected_index)
			_clear_dynamic_inspector()
			_sync_timeline()
	)
	_dynamic_inspector.add_child(del_btn)


## ==================== 技能列表操作 ====================
func _on_skill_list_selected(idx: int) -> void:
	if idx < 0 or idx >= _skill_list_items.size():
		return
	_current_skill = _skill_list_items[idx]
	_refresh_properties()
	_sync_timeline()
	_sync_preview()
	skill_selected.emit(_current_skill)


func _on_new_skill() -> void:
	var skill := SkillDataRes.new()
	skill.skill_name = "new_skill_%d" % _skill_list_items.size()
	_skill_list_items.append(skill)
	_refresh_skill_list()
	_current_skill = skill
	_refresh_properties()
	_sync_timeline()
	_sync_preview()
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
		_sync_timeline()
		_sync_preview()
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
	pass


## ==================== 图标 + 动画绑定 ====================
func _on_pick_icon() -> void:
	if not _current_skill:
		return
	if not _current_skill.ui:
		var UIData = load("res://addons/dnf_framework/resources/skill/skill_ui_data.gd")
		if UIData:
			_current_skill.ui = UIData.new()
	# EditorFileDialog 需在主插件协调，这里 emit 信号由外部处理
	# 临时方案：弹出原生文件选择对话框
	pass


func _on_pick_animation() -> void:
	if not _current_skill:
		return
	# EditorFileDialog 需在主插件协调
	pass


## ==================== 属性回调 ====================
func _on_skill_name_changed(new_text: String) -> void:
	if _current_skill:
		_current_skill.skill_name = new_text
		var idx := _skill_list_items.find(_current_skill)
		if idx >= 0 and _skill_list:
			_skill_list.set_item_text(idx, new_text if not new_text.is_empty() else "未命名技能")


func _on_display_name_changed(new_text: String) -> void:
	if _current_skill:
		_current_skill.display_name = new_text


func _on_mp_cost_changed(val: float) -> void:
	if _current_skill:
		_current_skill.mp_cost = int(val)


func _on_hp_cost_changed(val: float) -> void:
	if _current_skill:
		_current_skill.hp_cost = int(val)


func _on_cooldown_changed(val: float) -> void:
	if _current_skill:
		_current_skill.cooldown_frames = int(val)


func _on_damage_type_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.damage_type = _damage_type_option.get_item_id(idx)


func _on_element_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.element = _element_option.get_item_id(idx)


func _on_skill_coefficient_changed(val: float) -> void:
	if _current_skill:
		_current_skill.skill_coefficient = val


func _on_super_armor_selected(idx: int) -> void:
	if _current_skill:
		_current_skill.super_armor_level = _super_armor_option.get_item_id(idx)


func _on_cancelable_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.cancelable = pressed


func _on_cancel_into_changed(new_text: String) -> void:
	if _current_skill:
		var arr: Array[String] = []
		for s in new_text.split(","):
			var t := s.strip_edges()
			if not t.is_empty():
				arr.append(t)
		_current_skill.cancel_into = arr


func _on_ground_only_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.ground_only = pressed


func _on_air_usable_toggled(pressed: bool) -> void:
	if _current_skill:
		_current_skill.air_usable = pressed


func _on_priority_changed(val: float) -> void:
	if _current_skill:
		_current_skill.priority = int(val)
