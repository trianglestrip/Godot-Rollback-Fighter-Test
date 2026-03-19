class_name DNFAnimationPreview
extends Node2D

## 帧动画预览组件 — 放入场景即可自动播放
## 支持从目录加载独立帧图片，或直接指定 AnimationData 列表
## 播放时间 = 帧数 / (fps × speed_scale)

const P_AnimData = preload("res://addons/dnf_framework/resources/animation/animation_data.gd")
const P_FrameData = preload("res://addons/dnf_framework/resources/animation/frame_data.gd")
const P_FramePlayer = preload("res://addons/dnf_framework/runtime/frame/frame_player.gd")

signal animation_changed(anim_name: String)
signal all_animations_played

## 精灵帧图片所在目录（res:// 路径）
@export var sprite_folder: String = ""
## 预配置的动画列表（优先于 sprite_folder）
@export var animations: Array[Resource] = []
## 基础帧率
@export var fps: int = 12
## 全局速率倍率（影响所有动画，叠加在动画自身的 speed_scale 之上）
@export var speed_scale: float = 1.0
## 是否自动播放
@export var auto_play: bool = true
## 是否循环播放所有动画
@export var loop_all: bool = true
## 动画分组配置：格式为 {"动画名": [起始帧, 结束帧], ...}
@export var animation_groups: Dictionary = {}

var _sprite: Sprite2D
var _frame_player: DNFFramePlayer
var _anim_list: Array = []
var _current_anim_index: int = 0
var _label: Label


func _ready() -> void:
	_setup_nodes()
	if not sprite_folder.is_empty() or not animations.is_empty():
		_load_animations()
		if auto_play and not _anim_list.is_empty():
			_play_current()


func _setup_nodes() -> void:
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite2D"
	add_child(_sprite)

	_frame_player = P_FramePlayer.new()
	_frame_player.name = "FramePlayer"
	_frame_player.sprite = _sprite
	_frame_player.animation_finished.connect(_on_animation_finished)
	add_child(_frame_player)

	_label = Label.new()
	_label.name = "AnimNameLabel"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-60, -160)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(_label)


func _load_animations() -> void:
	if not animations.is_empty():
		_anim_list = animations.duplicate()
		return

	if sprite_folder.is_empty():
		return

	var textures := _load_textures_from_folder(sprite_folder)
	if textures.is_empty():
		push_warning("DNFAnimationPreview: 在 '%s' 中未找到图片" % sprite_folder)
		return

	if animation_groups.is_empty():
		var anim := _create_animation("all", textures, true)
		_anim_list.append(anim)
	else:
		for anim_name in animation_groups:
			var range_arr = animation_groups[anim_name]
			if range_arr is Array and range_arr.size() >= 2:
				var start_idx: int = range_arr[0]
				var end_idx: int = mini(range_arr[1], textures.size() - 1)
				var sub_textures: Array[Texture2D] = []
				for i in range(start_idx, end_idx + 1):
					if i < textures.size():
						sub_textures.append(textures[i])
				var is_loop = range_arr[2] if range_arr.size() > 2 else false
				var anim := _create_animation(anim_name, sub_textures, is_loop)
				_anim_list.append(anim)


func _load_textures_from_folder(folder_path: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var dir := DirAccess.open(folder_path)
	if dir == null:
		push_warning("DNFAnimationPreview: 无法打开目录 '%s'" % folder_path)
		return textures

	var file_names: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var ext := file_name.get_extension().to_lower()
			if ext == "png":
				file_names.append(file_name)
			elif ext == "import":
				var base := file_name.get_basename()
				if base.get_extension().to_lower() == "png":
					if not file_names.has(base):
						file_names.append(base)
		file_name = dir.get_next()
	dir.list_dir_end()

	file_names.sort()

	for fname in file_names:
		var full_path := folder_path.path_join(fname)
		var tex := load(full_path) as Texture2D
		if tex:
			textures.append(tex)

	return textures


func _create_animation(anim_name: String, textures: Array[Texture2D], is_loop: bool = false) -> Resource:
	var anim := P_AnimData.new()
	anim.anim_name = anim_name
	anim.fps = fps
	anim.speed_scale = speed_scale
	anim.loop = is_loop
	anim.frames = []
	for tex in textures:
		var fd := P_FrameData.new()
		fd.texture = tex
		fd.duration = 1
		anim.frames.append(fd)
	return anim


func _play_current() -> void:
	if _current_anim_index < 0 or _current_anim_index >= _anim_list.size():
		return
	var anim = _anim_list[_current_anim_index]
	_frame_player.play(anim)
	_label.text = anim.anim_name
	animation_changed.emit(anim.anim_name)


func _on_animation_finished(_anim_name: String) -> void:
	_current_anim_index += 1
	if _current_anim_index >= _anim_list.size():
		if loop_all:
			_current_anim_index = 0
		else:
			all_animations_played.emit()
			return
	_play_current()


func _process(delta: float) -> void:
	if _frame_player:
		_frame_player.advance(delta)


func initialize() -> void:
	_anim_list.clear()
	_current_anim_index = 0
	_load_animations()
	if auto_play and not _anim_list.is_empty():
		_play_current()


func play_animation(anim_name: String) -> void:
	for i in range(_anim_list.size()):
		if _anim_list[i].anim_name == anim_name:
			_current_anim_index = i
			_play_current()
			return
	push_warning("DNFAnimationPreview: 未找到动画 '%s'" % anim_name)


func play_next() -> void:
	_current_anim_index = (_current_anim_index + 1) % _anim_list.size()
	_play_current()


func play_prev() -> void:
	_current_anim_index = (_current_anim_index - 1 + _anim_list.size()) % _anim_list.size()
	_play_current()


func get_animation_names() -> PackedStringArray:
	var names := PackedStringArray()
	for anim in _anim_list:
		names.append(anim.anim_name)
	return names


func get_current_animation_name() -> String:
	if _current_anim_index >= 0 and _current_anim_index < _anim_list.size():
		return _anim_list[_current_anim_index].anim_name
	return ""
