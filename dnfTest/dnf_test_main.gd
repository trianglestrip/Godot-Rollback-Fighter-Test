extends Node2D

## DNF 帧动画测试主场景
## 加载 sm_body0000 目录中的所有帧图片，分组为不同动作，自动播放

@onready var preview: DNFAnimationPreview = $Character
@onready var info_label: Label = $UI/InfoLabel
@onready var anim_list: ItemList = $UI/AnimList

const SPRITE_FOLDER = "res://dnfTest/fromDNF/avatar/skin/sm_body0000/"

## DNF 格斗角色典型动作分组
## 格式: { "动画名": [起始帧索引, 结束帧索引, 是否循环] }
const ANIM_GROUPS := {
	"idle":         [0, 3, true],
	"walk":         [4, 11, true],
	"run":          [12, 19, true],
	"punch_a":      [20, 27, false],
	"punch_b":      [28, 35, false],
	"kick_a":       [36, 44, false],
	"kick_b":       [45, 53, false],
	"upper":        [54, 63, false],
	"crouch":       [64, 68, false],
	"crouch_atk":   [69, 78, false],
	"jump_up":      [79, 86, false],
	"jump_atk":     [87, 95, false],
	"dash":         [96, 103, false],
	"guard":        [104, 108, true],
	"hit_light":    [109, 114, false],
	"hit_heavy":    [115, 122, false],
	"knockdown":    [123, 133, false],
	"getup":        [134, 141, false],
	"special_a":    [142, 157, false],
	"special_b":    [158, 170, false],
	"victory":      [171, 178, true],
}


func _ready() -> void:
	if preview:
		preview.sprite_folder = SPRITE_FOLDER
		preview.animation_groups = ANIM_GROUPS
		preview.fps = 12
		preview.speed_scale = 1.0
		preview.auto_play = true
		preview.loop_all = true
		preview.initialize()
		preview.animation_changed.connect(_on_animation_changed)
		_populate_anim_list()


func _populate_anim_list() -> void:
	if anim_list == null or preview == null:
		return
	anim_list.clear()
	var names: PackedStringArray = preview.get_animation_names()
	for anim_name in names:
		anim_list.add_item(anim_name)
	if not names.is_empty():
		anim_list.select(0)


func _on_animation_changed(anim_name: String) -> void:
	if info_label:
		info_label.text = "当前动画: %s | ← → 切换 | 空格 重播" % anim_name
	if anim_list:
		var names: PackedStringArray = preview.get_animation_names()
		for i in range(names.size()):
			if names[i] == anim_name:
				anim_list.select(i)
				anim_list.ensure_current_is_visible()
				break


func _on_anim_list_item_selected(index: int) -> void:
	if preview and anim_list:
		var selected_name: String = anim_list.get_item_text(index)
		preview.play_animation(selected_name)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_RIGHT:
				if preview:
					preview.play_next()
			KEY_LEFT:
				if preview:
					preview.play_prev()
			KEY_SPACE:
				if preview:
					var cur: String = preview.get_current_animation_name()
					if not cur.is_empty():
						preview.play_animation(cur)
