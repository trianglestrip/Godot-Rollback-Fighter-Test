extends "res://addons/dnf_framework/runtime/character/dnf_character.gd"

## 阶段三示例：受击沙包（不主动攻击）

@onready var body_rect: ColorRect = $BodyRect
@onready var state_label: Label = $StateLabel
@onready var health_bar: ProgressBar = $HealthBar

const COLOR_IDLE := Color(0.7, 0.3, 0.3)
const COLOR_HIT := Color(1.0, 0.8, 0.2)
const COLOR_KNOCK := Color(0.9, 0.5, 0.1)
const COLOR_DOWN := Color(0.6, 0.2, 0.1)
const COLOR_AIR := Color(1.0, 0.6, 0.2)
const COLOR_GETUP := Color(0.6, 0.4, 0.4)


func _ready() -> void:
	health = max_health


func _get_move_direction() -> float:
	return 0.0


func _is_jump_pressed() -> bool:
	return false


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	_update_visuals()

	if health <= 0:
		health = max_health
		_change_state(DNFStates.State.IDLE)
		velocity = Vector2.ZERO


func _update_visuals() -> void:
	if body_rect:
		var c: Color
		match current_state:
			DNFStates.State.HIT_STUN: c = COLOR_HIT
			DNFStates.State.KNOCK_BACK: c = COLOR_KNOCK
			DNFStates.State.KNOCK_DOWN: c = COLOR_DOWN
			DNFStates.State.AIR_BORNE: c = COLOR_AIR
			DNFStates.State.GET_UP: c = COLOR_GETUP
			_: c = COLOR_IDLE
		body_rect.color = c

	if state_label:
		state_label.text = get_state_name() + " [" + str(state_tick) + "]"

	if health_bar:
		health_bar.value = float(health) / float(max_health) * 100.0
