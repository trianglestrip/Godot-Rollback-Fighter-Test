class_name InputBuffer
extends Node

## 基于帧计数的输入缓冲系统

signal buffer_input(input_name: String, frame: int)
signal buffer_cleared()
signal combo_detected(combo_name: String, input_sequence: Array)

@export var buffer_size: int = 10
@export var history_size: int = 60
@export var combo_definitions: Dictionary = {}

var _buffer: Array[Dictionary] = []
var _input_history: Array[Dictionary] = []
var _frame_count: int = 0
var _combos: Dictionary = {}


func _ready() -> void:
	set_process(false)
	_init_combos()


func _physics_process(_delta: float) -> void:
	_frame_count += 1
	_clean_expired_inputs()


func _init_combos() -> void:
	for combo_name in combo_definitions:
		_combos[combo_name] = combo_definitions[combo_name]


func _clean_expired_inputs() -> void:
	var i := 0
	while i < _buffer.size():
		if _frame_count - _buffer[i].frame > buffer_size:
			_buffer.remove_at(i)
		else:
			i += 1


func _check_combos() -> void:
	if _buffer.is_empty():
		return
	for combo_name in _combos:
		var seq: Array = _combos[combo_name]
		if _buffer.size() < seq.size():
			continue
		var matched := true
		var matched_inputs: Array = []
		for j in range(seq.size()):
			var idx := _buffer.size() - seq.size() + j
			if idx < 0 or _buffer[idx].input != seq[j]:
				matched = false
				break
			matched_inputs.append(_buffer[idx].input)
		if matched:
			combo_detected.emit(combo_name, matched_inputs)
			_buffer.resize(_buffer.size() - seq.size())
			return


func add_input(input_name: String) -> void:
	var entry := {"input": input_name, "frame": _frame_count}
	_buffer.append(entry)
	if _buffer.size() > buffer_size:
		_buffer.remove_at(0)
	_check_combos()
	buffer_input.emit(input_name, _frame_count)


func has_input(input_name: String, max_age: int = -1) -> bool:
	var age_limit := max_age if max_age > 0 else buffer_size
	for entry in _buffer:
		if entry.input == input_name and _frame_count - entry.frame <= age_limit:
			return true
	return false


func consume_input(input_name: String, max_age: int = -1) -> bool:
	var age_limit := max_age if max_age > 0 else buffer_size
	for i in range(_buffer.size() - 1, -1, -1):
		if _buffer[i].input == input_name and _frame_count - _buffer[i].frame <= age_limit:
			_buffer.remove_at(i)
			return true
	return false


func has_input_sequence(sequence: Array, max_window: int = -1) -> bool:
	if _buffer.size() < sequence.size():
		return false
	var window := max_window if max_window > 0 else buffer_size
	var filtered: Array[Dictionary] = []
	for entry in _buffer:
		if _frame_count - entry.frame <= window:
			filtered.append(entry)
	if filtered.size() < sequence.size():
		return false
	for i in range(filtered.size() - sequence.size() + 1):
		var matched := true
		for j in range(sequence.size()):
			if filtered[i + j].input != sequence[j]:
				matched = false
				break
		if matched:
			return true
	return false


func clear() -> void:
	_buffer.clear()
	buffer_cleared.emit()


func get_buffer_size() -> int:
	return _buffer.size()


func add_combo(combo_name: String, input_sequence: Array) -> void:
	_combos[combo_name] = input_sequence


func remove_combo(combo_name: String) -> void:
	_combos.erase(combo_name)


func get_all_combos() -> Dictionary:
	return _combos.duplicate()


func record_direction(direction: String) -> void:
	var entry := {"direction": direction, "frame": _frame_count}
	_input_history.append(entry)
	if _input_history.size() > history_size:
		_input_history.remove_at(0)


func get_input_history() -> Array[Dictionary]:
	return _input_history


func get_frame_count() -> int:
	return _frame_count


func set_frame_count(frame: int) -> void:
	_frame_count = frame


func _save_state() -> Dictionary:
	return {
		"buffer": _buffer.duplicate(true),
		"history": _input_history.duplicate(true),
		"frame": _frame_count,
	}


func _load_state(state: Dictionary) -> void:
	_buffer.assign(state.get("buffer", []))
	_input_history.assign(state.get("history", []))
	_frame_count = state.get("frame", 0)
