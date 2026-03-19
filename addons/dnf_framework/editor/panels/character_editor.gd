@tool
extends Control

## 角色编辑器面板 — 编辑 DNFCharacterData 资源

signal character_saved(path: String)

const CharacterData = preload("res://addons/dnf_framework/resources/character/character_data.gd")
const CharacterStats = preload("res://addons/dnf_framework/resources/character/character_stats.gd")
const SkillDataV2 = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const AnimationData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")

var _current_character: Resource

## UI 引用
var _char_name_edit: LineEdit
var _display_name_edit: LineEdit
var _atlas_btn: Button
var _atlas_preview: TextureRect
var _anim_list: ItemList
var _skill_list: ItemList
var _stats_spins: Dictionary = {}  ## 属性名 -> SpinBox


func _ready() -> void:
	_build_ui()


## 构建完整 UI
func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var main_v := VBoxContainer.new()
	scroll.add_child(main_v)

	## 基本信息
	var info_group := _make_group("基本信息")
	main_v.add_child(info_group)

	_char_name_edit = LineEdit.new()
	_char_name_edit.placeholder_text = "character_name"
	_char_name_edit.text_changed.connect(_on_char_name_changed)
	info_group.add_child(_make_row("角色名", _char_name_edit))

	_display_name_edit = LineEdit.new()
	_display_name_edit.placeholder_text = "显示名称"
	_display_name_edit.text_changed.connect(_on_display_name_changed)
	info_group.add_child(_make_row("显示名", _display_name_edit))

	## Atlas 区域
	var atlas_group := _make_group("图集")
	main_v.add_child(atlas_group)

	var atlas_row := HBoxContainer.new()
	_atlas_btn = Button.new()
	_atlas_btn.text = "加载图集"
	_atlas_btn.pressed.connect(_on_load_atlas)
	atlas_row.add_child(_atlas_btn)

	_atlas_preview = TextureRect.new()
	_atlas_preview.custom_minimum_size = Vector2(128, 128)
	_atlas_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_atlas_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	atlas_row.add_child(_atlas_preview)

	atlas_group.add_child(atlas_row)

	## 动画列表
	var anim_group := _make_group("动画")
	main_v.add_child(anim_group)

	_anim_list = ItemList.new()
	_anim_list.custom_minimum_size.y = 120
	_anim_list.item_selected.connect(_on_anim_selected)
	anim_group.add_child(_anim_list)

	var anim_btns := HBoxContainer.new()
	var btn_add_anim := Button.new()
	btn_add_anim.text = "添加动画"
	btn_add_anim.pressed.connect(_on_add_animation)
	anim_btns.add_child(btn_add_anim)

	var btn_del_anim := Button.new()
	btn_del_anim.text = "删除动画"
	btn_del_anim.pressed.connect(_on_delete_animation)
	anim_btns.add_child(btn_del_anim)

	anim_group.add_child(anim_btns)

	## 技能列表
	var skill_group := _make_group("技能")
	main_v.add_child(skill_group)

	_skill_list = ItemList.new()
	_skill_list.custom_minimum_size.y = 120
	_skill_list.item_selected.connect(_on_skill_selected)
	skill_group.add_child(_skill_list)

	var skill_btns := HBoxContainer.new()
	var btn_add_skill := Button.new()
	btn_add_skill.text = "添加技能"
	btn_add_skill.pressed.connect(_on_add_skill)
	skill_btns.add_child(btn_add_skill)

	var btn_remove_skill := Button.new()
	btn_remove_skill.text = "移除技能"
	btn_remove_skill.pressed.connect(_on_remove_skill)
	skill_btns.add_child(btn_remove_skill)

	skill_group.add_child(skill_btns)

	## 属性
	var stats_group := _make_group("角色属性")
	main_v.add_child(stats_group)

	var stat_names := [
		"max_hp", "max_mp", "strength", "intelligence", "vitality", "spirit",
		"physical_attack", "magical_attack", "move_speed", "attack_speed"
	]
	var stat_labels := {
		"max_hp": "最大HP",
		"max_mp": "最大MP",
		"strength": "力量",
		"intelligence": "智力",
		"vitality": "体力",
		"spirit": "精神",
		"physical_attack": "物攻",
		"magical_attack": "魔攻",
		"move_speed": "移速",
		"attack_speed": "攻速"
	}

	var grid := GridContainer.new()
	grid.columns = 2

	for name_key in stat_names:
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = 999999
		spin.step = 0.01 if name_key in ["move_speed", "attack_speed"] else 1.0
		spin.value_changed.connect(_on_stat_changed.bind(name_key))
		_stats_spins[name_key] = spin

		var row := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = stat_labels.get(name_key, name_key)
		lbl.custom_minimum_size.x = 80
		row.add_child(lbl)
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(spin)
		grid.add_child(row)

	stats_group.add_child(grid)

	## 底部按钮
	var bottom_btns := HBoxContainer.new()
	var btn_new := Button.new()
	btn_new.text = "新建角色"
	btn_new.pressed.connect(_on_new_character)
	bottom_btns.add_child(btn_new)

	var btn_save := Button.new()
	btn_save.text = "保存角色"
	btn_save.pressed.connect(_on_save_character)
	bottom_btns.add_child(btn_save)

	var btn_load := Button.new()
	btn_load.text = "加载角色"
	btn_load.pressed.connect(_on_load_character)
	bottom_btns.add_child(btn_load)

	main_v.add_child(bottom_btns)


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
	lbl.custom_minimum_size.x = 80
	row.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


## 加载角色到编辑器
func load_character(char_data: Resource) -> void:
	_current_character = char_data
	_refresh_all()


## 保存角色到路径
func save_character(path: String) -> void:
	if _current_character == null:
		return
	var err := ResourceSaver.save(_current_character, path)
	if err == OK:
		character_saved.emit(path)


func _refresh_all() -> void:
	if _current_character == null:
		_char_name_edit.text = ""
		_display_name_edit.text = ""
		_atlas_preview.texture = null
		_anim_list.clear()
		_skill_list.clear()
		_refresh_stats(null)
		return

	_char_name_edit.text = _current_character.character_name
	_display_name_edit.text = _current_character.display_name
	_atlas_preview.texture = _current_character.atlas

	_anim_list.clear()
	var anims: Dictionary = _current_character.animations
	for anim_name in anims.keys():
		_anim_list.add_item(anim_name)

	_skill_list.clear()
	var skills: Array = _current_character.skills
	for s in skills:
		var name_str: String = s.skill_name if s else ""
		if name_str.is_empty():
			name_str = "未命名"
		_skill_list.add_item(name_str)

	var stats = _current_character.stats
	_refresh_stats(stats)


func _refresh_stats(stats: Resource) -> void:
	if stats == null:
		for key in _stats_spins:
			_stats_spins[key].value = 0
		return

	for key in _stats_spins:
		var val = stats.get(key)
		if val != null:
			_stats_spins[key].value = val


func _on_char_name_changed(new_text: String) -> void:
	if _current_character:
		_current_character.set("character_name", new_text)


func _on_display_name_changed(new_text: String) -> void:
	if _current_character:
		_current_character.set("display_name", new_text)


func _on_load_atlas() -> void:
	# 实际项目中由 EditorPlugin 打开 EditorFileDialog
	if _current_character == null:
		return
	# 占位：需要文件对话框


func _on_anim_selected(_idx: int) -> void:
	pass


func _on_skill_selected(_idx: int) -> void:
	pass


func _on_add_animation() -> void:
	if _current_character == null:
		return
	var anims: Dictionary = _current_character.animations
	var base_name := "new_anim"
	var name_key := base_name
	var i := 0
	while anims.has(name_key):
		i += 1
		name_key = "%s_%d" % [base_name, i]
	var anim_data := AnimationData.new()
	anim_data.anim_name = name_key
	anims[name_key] = anim_data
	_current_character.set("animations", anims)
	_anim_list.add_item(name_key)


func _on_delete_animation() -> void:
	if _current_character == null:
		return
	var idx := _anim_list.get_selected_items()
	if idx.is_empty():
		return
	var anim_name := _anim_list.get_item_text(idx[0])
	var anims: Dictionary = _current_character.animations
	anims.erase(anim_name)
	_current_character.set("animations", anims)
	_refresh_all()


func _on_add_skill() -> void:
	if _current_character == null:
		return
	var skill := SkillDataV2.new()
	skill.skill_name = "new_skill_%d" % _current_character.skills.size()
	var skills: Array = _current_character.skills
	skills.append(skill)
	_current_character.set("skills", skills)
	_skill_list.add_item(skill.skill_name)


func _on_remove_skill() -> void:
	if _current_character == null:
		return
	var idx := _skill_list.get_selected_items()
	if idx.is_empty():
		return
	var skills: Array = _current_character.skills
	if idx[0] < skills.size():
		skills.remove_at(idx[0])
		_current_character.set("skills", skills)
		_refresh_all()


func _on_stat_changed(val: float, name_key: String) -> void:
	if _current_character == null:
		return
	var stats = _current_character.stats
	if stats == null:
		stats = CharacterStats.new()
		_current_character.set("stats", stats)
	stats.set(name_key, val)


func _on_new_character() -> void:
	var char_data := CharacterData.new()
	char_data.character_name = "new_character"
	char_data.stats = CharacterStats.new()
	char_data.animations = {}
	char_data.skills = []
	load_character(char_data)


func _on_save_character() -> void:
	if _current_character == null:
		return
	var path := _current_character.resource_path
	if path.is_empty():
		path = "res://new_character.tres"
	save_character(path)


func _on_load_character() -> void:
	# 占位：由 EditorPlugin 打开文件对话框
	pass
