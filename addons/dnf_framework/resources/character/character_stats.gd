class_name DNFCharacterStats
extends Resource

## 角色属性 — DNF 四维 + 攻防 + 暴击 + 属性强化

@export_group("基础属性")
## 最大生命值
@export var max_hp: int = 1000
## 最大魔力值
@export var max_mp: int = 500

@export_group("四维属性")
## 力量（影响物理攻击力）
@export var strength: int = 100
## 智力（影响魔法攻击力）
@export var intelligence: int = 100
## 体力（影响最大HP和物理防御）
@export var vitality: int = 100
## 精神（影响最大MP和魔法防御）
@export var spirit: int = 100

@export_group("攻击力")
## 物理攻击力
@export var physical_attack: int = 200
## 魔法攻击力
@export var magical_attack: int = 200
## 独立攻击力
@export var independent_attack: int = 200

@export_group("防御力")
## 物理防御力
@export var physical_defense: int = 100
## 魔法防御力
@export var magical_defense: int = 100

@export_group("速度")
## 攻击速度（1.0 = 基础速度，1.5 = 加速50%）
@export var attack_speed: float = 1.0
## 施放速度（1.0 = 基础速度）
@export var cast_speed: float = 1.0
## 移动速度（像素/帧）
@export var move_speed: float = 5.0

@export_group("暴击")
## 物理暴击率（0.05 = 5%）
@export var physical_crit: float = 0.05
## 魔法暴击率（0.05 = 5%）
@export var magical_crit: float = 0.05
## 暴击伤害加成（0.5 = 额外50%伤害）
@export var crit_damage: float = 0.5

@export_group("命中与回避")
## 命中率（1.0 = 100%基础命中）
@export var accuracy: float = 1.0
## 回避率（0.0 = 不回避）
@export var evasion: float = 0.0

@export_group("属性强化")
## 火属性强化
@export var fire_enhance: int = 0
## 冰属性强化
@export var ice_enhance: int = 0
## 光属性强化
@export var light_enhance: int = 0
## 暗属性强化
@export var dark_enhance: int = 0

@export_group("属性抗性")
## 火属性抗性
@export var fire_resist: int = 0
## 冰属性抗性
@export var ice_resist: int = 0
## 光属性抗性
@export var light_resist: int = 0
## 暗属性抗性
@export var dark_resist: int = 0
