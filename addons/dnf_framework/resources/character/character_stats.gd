class_name DNFCharacterStats
extends Resource

## 角色属性 — DNF 四维 + 攻防 + 暴击 + 属性强化

@export_group("基础")
@export var max_hp: int = 1000
@export var max_mp: int = 500

@export_group("四维属性")
@export var strength: int = 100
@export var intelligence: int = 100
@export var vitality: int = 100
@export var spirit: int = 100

@export_group("攻击")
@export var physical_attack: int = 200
@export var magical_attack: int = 200
@export var independent_attack: int = 200

@export_group("防御")
@export var physical_defense: int = 100
@export var magical_defense: int = 100

@export_group("速度")
@export var attack_speed: float = 0.0
@export var cast_speed: float = 0.0
@export var move_speed: float = 5.0

@export_group("暴击")
@export var physical_crit: float = 0.05
@export var magical_crit: float = 0.05
@export var crit_damage: float = 0.5

@export_group("命中/回避")
@export var accuracy: float = 1.0
@export var evasion: float = 0.0

@export_group("属性强化")
@export var fire_enhance: int = 0
@export var ice_enhance: int = 0
@export var light_enhance: int = 0
@export var dark_enhance: int = 0

@export_group("属性抗性")
@export var fire_resist: int = 0
@export var ice_resist: int = 0
@export var light_resist: int = 0
@export var dark_resist: int = 0
