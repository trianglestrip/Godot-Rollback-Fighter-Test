extends Node2D

## 阶段五：完整双人对战示例
## P1: WASD移动 W跳 S+方向奔跑 Space冲刺 J轻攻 K重攻
## P2: 方向键移动 Up跳 Down+方向奔跑 Numpad0冲刺 Numpad1轻攻 Numpad2重攻
## 连段路线: 轻攻(J/Num1) -> 重攻(K/Num2) -> 轻攻(J/Num1 上挑击飞)

@onready var p1_name: Label = $HUD/P1Name
@onready var p2_name: Label = $HUD/P2Name
@onready var round_label: Label = $HUD/RoundLabel

var _round_timer: int = 0


func _physics_process(_delta: float) -> void:
	_round_timer += 1
	if round_label:
		var seconds := _round_timer / 60
		round_label.text = "TIME: " + str(seconds)
