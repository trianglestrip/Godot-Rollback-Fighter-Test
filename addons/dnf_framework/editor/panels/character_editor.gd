@tool
extends Control

## 角色编辑器面板 — 编辑 DNFCharacterData 资源

signal character_saved(path: String)

const CharacterData = preload("res://addons/dnf_framework/resources/character/character_data.gd")
const CharacterStats = preload("res://addons/dnf_framework/resources/character/character_stats.gd")
const SkillDataV2 = preload("res://addons/dnf_framework/resources/skill/skill_data_v2.gd")
const AnimationData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")

var _current_character: Resource

var _char_name_edit: LineEdit
var _display_name_edit: LineEdit
var _atlas_btn: Button
var _atlas_preview: TextureRect
var _anim_list: ItemList
var _skill_list: ItemList
var _stats_spins: Dictionary = {}
var _file_dialog: FileDialog
var _status_label: Label


func _ready() -> void:
	_build_ui()
	_on_new_character()


func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var root := HSplitContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	## ===== 左列：基本信息 + 图集 =====
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 280
	root.add_child(left)

	## 操作按钮（置顶）
	var top_btns := HBoxContainer.new()
	var btn_new := Button.new()
	btn_new.text = "新建"
	btn_new.pressed.connect(_on_new_character)
	top_btns.add_child(btn_new)
	var btn_save := Button.new()
	btn_save.text = "保存"
	btn_save.pressed.connect(_on_save_character)
	top_btns.add_child(btn_save)
	var btn_load := Button.new()
	btn_load.text = "加载"
	btn_load.pressed.connect(_on_load_character)
	top_btns.add_child(btn_load)
	left.add_child(top_btns)

	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", 11)
	_status_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	left.add_child(_status_label)

	_char_name_edit = LineEdit.new()
	_char_name_edit.placeholder_text = "character_name"
	_char_name_edit.text_changed.connect(_on_char_name_changed)
	left.add_child(_make_row("角色名", _char_name_edit))

	_display_name_edit = LineEdit.new()
	_display_name_edit.placeholder_text = "显示名称"
	_display_name_edit.text_changed.connect(_on_display_name_changed)
	left.add_child(_make_row("显示名", _display_name_edit))

	## 图集
	var atlas_row := HBoxContainer.new()
	_atlas_btn = Button.new()
	_atlas_btn.text = "加载图集"
	_atlas_btn.pressed.connect(_on_load_atlas)
	atlas_row.add_child(_atlas_btn)
	_atlas_preview = TextureRect.new()
	_atlas_preview.custom_minimum_size = Vector2(80, 80)
	_atlas_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_atlas_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	atlas_row.add_child(_atlas_preview)
	left.add_child(atlas_row)

	## ===== 中列：动画 + 技能 =====
	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(mid)

	var anim_lbl := Label.new()
	anim_lbl.text = "动画列表"
	anim_lbl.add_theme_font_size_override("font_size", 13)
	mid.add_child(anim_lbl)

	_anim_list = ItemList.new()
	_anim_list.custom_minimum_size.y = 80
	_anim_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_anim_list.item_selected.connect(_on_anim_selected)
	mid.add_child(_anim_list)

	var anim_btns := HBoxContainer.new()
	var btn_add_anim := Button.new()
	btn_add_anim.text = "+ 动画"
	btn_add_anim.pressed.connect(_on_add_animation)
	anim_btns.add_child(btn_add_anim)
	var btn_del_anim := Button.new()
	btn_del_anim.text = "- 删除"
	btn_del_anim.pressed.connect(_on_delete_animation)
	anim_btns.add_child(btn_del_anim)
	mid.add_child(anim_btns)

	mid.add_child(HSeparator.new())

	var skill_lbl := Label.new()
	skill_lbl.text = "技能列表"
	skill_lbl.add_theme_font_size_override("font_size", 13)
	mid.add_child(skill_lbl)

	_skill_list = ItemList.new()
	_skill_list.custom_minimum_size.y = 80
	_skill_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_skill_list.item_selected.connect(_on_skill_selected)
	mid.add_child(_skill_list)

	var skill_btns := HBoxContainer.new()
	var btn_add_skill := Button.new()
	btn_add_skill.text = "+ 技能"
	btn_add_skill.pressed.connect(_on_add_skill)
	skill_btns.add_child(btn_add_skill)
	var btn_remove_skill := Button.new()
	btn_remove_skill.text = "- 移除"
	btn_remove_skill.pressed.connect(_on_remove_skill)
	skill_btns.add_child(btn_remove_skill)
	mid.add_child(skill_btns)

	## ===== 右列：属性 =====
	var right := VBoxContainer.new()
	right.custom_minimum_size.x = 240
	root.add_child(right)

	var stat_lbl := Label.new()
	stat_lbl.text = "角色属性"
	stat_lbl.add_theme_font_size_override("font_size", 13)
	right.add_child(stat_lbl)

	var stat_names := [
		"max_hp", "max_mp", "strength", "intelligence", "vitality", "spirit",
		"physical_attack", "magical_attack", "move_speed", "attack_speed"
	]
	var stat_labels := {
		"max_hp": "最大HP", "max_mp": "最大MP",
		"strength": "力量", "intelligence": "智力",
		"vitality": "体力", "spirit": "精神",
		"physical_attack": "物攻", "magical_attack": "魔攻",
		"move_speed": "移速", "attack_speed": "攻速"
	}

	var grid := GridContainer.new()
	grid.columns = 4
	for name_key in stat_names:
		var lbl := Label.new()
		lbl.text = stat_labels.get(name_key, name_key)
		lbl.custom_minimum_size.x = 40
		grid.add_child(lbl)
		var spin := SpinBox.new()
		spin.min_value = 0
		spin.max_value = 999999
		spin.step = 0.01 if name_key in ["move_speed", "attack_speed"] else 1.0
		spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spin.value_changed.connect(_on_stat_changed.bind(name_key))
		_stats_spins[name_key] = spin
		grid.add_child(spin)
	right.add_child(grid)

	## FileDialog
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.size = Vector2i(800, 500)
	add_child(_file_dialog)


func _make_row(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size.x = 50
	row.add_child(lbl)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row


func _set_status(text: String) -> void:
	if _status_label:
		_status_label.text = text


func _disconnect_file_dialog() -> void:
	if _file_dialog.file_selected.is_connected(_on_atlas_file_selected):
		_file_dialog.file_selected.disconnect(_on_atlas_file_selected)
	if _file_dialog.file_selected.is_connected(_on_load_file_selected):
		_file_dialog.file_selected.disconnect(_on_load_file_selected)
	if _file_dialog.file_selected.is_connected(_on_save_file_selected):
		_file_dialog.file_selected.disconnect(_on_save_file_selected)


## ===================== 刷新 =====================

func load_character(char_data: Resource) -> void:
	_current_character = char_data
	_refresh_all()


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

	_refresh_stats(_current_character.stats)


func _refresh_stats(stats: Resource) -> void:
	if stats == null:
		for key in _stats_spins:
			_stats_spins[key].value = 0
		return
	for key in _stats_spins:
		var val = stats.get(key)
		if val != null:
			_stats_spins[key].value = val


## ===================== 基本信息 =====================

func _on_char_name_changed(new_text: String) -> void:
	if _current_character:
		_current_character.set("character_name", new_text)

func _on_display_name_changed(new_text: String) -> void:
	if _current_character:
		_current_character.set("display_name", new_text)


## ===================== 图集 =====================

func _on_load_atlas() -> void:
	if _current_character == null:
		return
	_disconnect_file_dialog()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.filters = PackedStringArray(["*.png ; PNG 图片", "*.tres ; Godot 资源"])
	_file_dialog.title = "选择图集纹理"
	_file_dialog.file_selected.connect(_on_atlas_file_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()


func _on_atlas_file_selected(path: String) -> void:
	if _current_character == null:
		return
	var tex := load(path) as Texture2D
	if tex:
		_current_character.set("atlas", tex)
		_atlas_preview.texture = tex
		_set_status("图集已加载: " + path.get_file())


## ===================== 动画 =====================

func _on_anim_selected(_idx: int) -> void:
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
	_set_status("已添加动画: " + name_key)

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
	_set_status("已删除动画: " + anim_name)


## ===================== 技能 =====================

func _on_skill_selected(_idx: int) -> void:
	pass

func _on_add_skill() -> void:
	if _current_character == null:
		return
	var skill := SkillDataV2.new()
	skill.skill_name = "new_skill_%d" % _current_character.skills.size()
	var skills: Array = _current_character.skills
	skills.append(skill)
	_current_character.set("skills", skills)
	_skill_list.add_item(skill.skill_name)
	_set_status("已添加技能: " + skill.skill_name)

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


## ===================== 属性 =====================

func _on_stat_changed(val: float, name_key: String) -> void:
	if _current_character == null:
		return
	var stats = _current_character.stats
	if stats == null:
		stats = CharacterStats.new()
		_current_character.set("stats", stats)
	stats.set(name_key, val)


## ===================== 新建/保存/加载 =====================

func _on_new_character() -> void:
	var char_data := CharacterData.new()
	char_data.character_name = "new_character"
	char_data.stats = CharacterStats.new()
	char_data.animations = {}
	char_data.skills = []
	load_character(char_data)
	_set_status("已新建角色")

func _on_save_character() -> void:
	if _current_character == null:
		return
	_disconnect_file_dialog()
	_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	_file_dialog.filters = PackedStringArray(["*.tres ; Godot 资源"])
	_file_dialog.title = "保存角色资源"
	if not _current_character.character_name.is_empty():
		_file_dialog.current_file = _current_character.character_name + ".tres"
	_file_dialog.file_selected.connect(_on_save_file_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_save_file_selected(path: String) -> void:
	if _current_character == null:
		return
	var err := ResourceSaver.save(_current_character, path)
	if err == OK:
		character_saved.emit(path)
		_set_status("已保存: " + path.get_file())
	else:
		_set_status("保存失败! 错误码: %d" % err)

func _on_load_character() -> void:
	_disconnect_file_dialog()
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.filters = PackedStringArray(["*.tres ; Godot 资源"])
	_file_dialog.title = "加载角色资源"
	_file_dialog.file_selected.connect(_on_load_file_selected, CONNECT_ONE_SHOT)
	_file_dialog.popup_centered()

func _on_load_file_selected(path: String) -> void:
	var res := load(path)
	if res == null:
		_set_status("加载失败: " + path)
		return
	_current_character = res
	_refresh_all()
	_set_status("已加载: " + path.get_file())
