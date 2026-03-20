class_name DNFAnimationPreview
extends Node2D

## 帧动画预览组件 — 放入场景即可自动播放
## 支持从目录加载独立帧图片，自动创建原生 SpriteFrames

const P_AnimSprite = preload("res://addons/dnf_framework/runtime/frame/animated_sprite.gd")

signal animation_changed(anim_name: String)
signal all_animations_played

@export var sprite_folder: String = ""
@export var fps: int = 12
@export var speed_scale: float = 1.0
@export var auto_play: bool = true
@export var loop_all: bool = true
@export var animation_groups: Dictionary = {}

var _animated_sprite: AnimatedSprite2D
var _anim_names: Array[String] = []
var _current_anim_index: int = 0
var _label: Label


func _ready() -> void:
	_setup_nodes()
	if not sprite_folder.is_empty():
		_load_animations()
		if auto_play and not _anim_names.is_empty():
			_play_current()


func _setup_nodes() -> void:
	_animated_sprite = P_AnimSprite.new()
	_animated_sprite.name = "AnimatedSprite"
	_animated_sprite.sprite_frames = SpriteFrames.new()
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	add_child(_animated_sprite)

	_label = Label.new()
	_label.name = "AnimNameLabel"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-60, -160)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(_label)


func _load_animations() -> void:
	if sprite_folder.is_empty():
		return

	var textures := _load_textures_from_folder(sprite_folder)
	if textures.is_empty():
		push_warning("DNFAnimationPreview: 在 '%s' 中未找到图片" % sprite_folder)
		return

	var sf := SpriteFrames.new()
	# Remove the auto-created "default" animation
	if sf.has_animation("default"):
		sf.remove_animation("default")

	if animation_groups.is_empty():
		sf.add_animation("all")
		sf.set_animation_speed("all", fps)
		sf.set_animation_loop("all", true)
		for tex in textures:
			sf.add_frame("all", tex)
		_anim_names.append("all")
	else:
		for anim_name in animation_groups:
			var range_arr = animation_groups[anim_name]
			if range_arr is Array and range_arr.size() >= 2:
				var start_idx: int = range_arr[0]
				var end_idx: int = mini(range_arr[1], textures.size() - 1)
				var is_loop: bool = range_arr[2] if range_arr.size() > 2 else false
				sf.add_animation(anim_name)
				sf.set_animation_speed(anim_name, fps)
				sf.set_animation_loop(anim_name, is_loop)
				for i in range(start_idx, end_idx + 1):
					if i < textures.size():
						sf.add_frame(anim_name, textures[i])
				_anim_names.append(anim_name)

	_animated_sprite.sprite_frames = sf
	_animated_sprite.speed_scale = speed_scale


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


func _play_current() -> void:
	if _current_anim_index < 0 or _current_anim_index >= _anim_names.size():
		return
	var anim_name: String = _anim_names[_current_anim_index]
	_animated_sprite.play(anim_name)
	_label.text = anim_name
	animation_changed.emit(anim_name)


func _on_animation_finished() -> void:
	_current_anim_index += 1
	if _current_anim_index >= _anim_names.size():
		if loop_all:
			_current_anim_index = 0
		else:
			all_animations_played.emit()
			return
	_play_current()


func initialize() -> void:
	_anim_names.clear()
	_current_anim_index = 0
	_load_animations()
	if auto_play and not _anim_names.is_empty():
		_play_current()


func play_animation(anim_name: String) -> void:
	for i in range(_anim_names.size()):
		if _anim_names[i] == anim_name:
			_current_anim_index = i
			_play_current()
			return
	push_warning("DNFAnimationPreview: 未找到动画 '%s'" % anim_name)


func play_next() -> void:
	_current_anim_index = (_current_anim_index + 1) % _anim_names.size()
	_play_current()


func play_prev() -> void:
	_current_anim_index = (_current_anim_index - 1 + _anim_names.size()) % _anim_names.size()
	_play_current()


func get_animation_names() -> PackedStringArray:
	var names := PackedStringArray()
	for n in _anim_names:
		names.append(n)
	return names


func get_current_animation_name() -> String:
	if _current_anim_index >= 0 and _current_anim_index < _anim_names.size():
		return _anim_names[_current_anim_index]
	return ""
