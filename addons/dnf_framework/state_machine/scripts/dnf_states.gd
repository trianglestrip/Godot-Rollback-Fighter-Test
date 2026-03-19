class_name DNFStates

## DNF 格斗游戏核心状态枚举

enum State {
	IDLE,
	WALK,
	RUN,
	JUMP,
	FALL,
	LAND,
	ATTACK,
	SKILL,
	HIT_STUN,
	KNOCK_DOWN,
	KNOCK_BACK,
	AIR_BORNE,
	GET_UP,
	BLOCK,
	GUARD_BREAK,
	DASH,
	BACK_DASH,
}


## 是否是可操作的状态（可以接受输入切换）
static func is_actionable(state: State) -> bool:
	return state in [
		State.IDLE,
		State.WALK,
		State.RUN,
		State.FALL,
		State.LAND,
	]


## 是否是受击/不可控状态
static func is_hit_state(state: State) -> bool:
	return state in [
		State.HIT_STUN,
		State.KNOCK_DOWN,
		State.KNOCK_BACK,
		State.AIR_BORNE,
		State.GUARD_BREAK,
	]


## 是否在空中
static func is_airborne(state: State) -> bool:
	return state in [
		State.JUMP,
		State.FALL,
		State.AIR_BORNE,
	]


## 是否是攻击状态
static func is_attacking(state: State) -> bool:
	return state in [
		State.ATTACK,
		State.SKILL,
	]


## 获取状态名称字符串
static func state_name(state: State) -> String:
	match state:
		State.IDLE: return "IDLE"
		State.WALK: return "WALK"
		State.RUN: return "RUN"
		State.JUMP: return "JUMP"
		State.FALL: return "FALL"
		State.LAND: return "LAND"
		State.ATTACK: return "ATTACK"
		State.SKILL: return "SKILL"
		State.HIT_STUN: return "HIT_STUN"
		State.KNOCK_DOWN: return "KNOCK_DOWN"
		State.KNOCK_BACK: return "KNOCK_BACK"
		State.AIR_BORNE: return "AIR_BORNE"
		State.GET_UP: return "GET_UP"
		State.BLOCK: return "BLOCK"
		State.GUARD_BREAK: return "GUARD_BREAK"
		State.DASH: return "DASH"
		State.BACK_DASH: return "BACK_DASH"
	return "UNKNOWN"
