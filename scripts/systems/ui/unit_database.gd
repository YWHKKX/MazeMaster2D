extends RefCounted
class_name UnitDatabase

## 单位数据库
## 存储所有22种单位的基础信息（属性、描述、工作流等）

var _unit_data: Dictionary = {}  # unit_type (SpecificEntityType) -> UnitData

## 单位数据类
class UnitData:
	var unit_type: Enums.SpecificEntityType
	var name: String
	var category: String  # "功能类" 或 "战斗类"
	var race: String  # 种族（哥布林、地精、兽人等）
	var description: String
	var workflows: Array[String] = []  # 工作流名称列表
	
	# 单位属性（9项）
	var max_health: int = 100  # 生命值
	var attack_power: int = 5  # 攻击力
	var attack_cooldown: float = 2.0  # 攻击冷却（秒）
	var attack_range: int = 15  # 攻击范围（像素）
	var pursuit_range: int = 45  # 追击范围（像素）
	var armor_value: int = 0  # 护甲值
	var body_size: float = 1.0  # 体型大小
	var move_speed: float = 1.0  # 移动速度（瓦块/秒）
	var is_ranged: bool = false  # 是否为远程单位
	
	func _init(p_unit_type: Enums.SpecificEntityType, p_name: String, p_category: String, p_race: String, p_description: String, 
			p_max_health: int = 100, p_attack_power: int = 5, p_attack_cooldown: float = 2.0, p_attack_range: int = 15,
			p_pursuit_range: int = 45, p_armor_value: int = 0, p_body_size: float = 1.0, p_move_speed: float = 1.0,
			p_is_ranged: bool = false):
		unit_type = p_unit_type
		name = p_name
		category = p_category
		race = p_race
		description = p_description
		max_health = p_max_health
		attack_power = p_attack_power
		attack_cooldown = p_attack_cooldown
		attack_range = p_attack_range
		pursuit_range = p_pursuit_range
		armor_value = p_armor_value
		body_size = p_body_size
		move_speed = p_move_speed
		is_ranged = p_is_ranged

## 构造函数
func _init():
	_initialize_unit_data()

## 初始化单位数据
func _initialize_unit_data() -> void:
	# 功能类单位（4种）
	
	# 1. 哥布林（Goblin）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN,
		"哥布林",
		"功能类",
		"哥布林",
		"基础工人单位，负责挖掘金矿。遇敌时会逃跑。",
		100,  # max_health
		5,    # attack_power
		2.0,  # attack_cooldown
		15,   # attack_range
		45,   # pursuit_range (attack_range * 3)
		0,    # armor_value
		1.0,  # body_size
		1.0,  # move_speed (瓦块/秒)
		false # is_ranged
	)
	
	# 2. 地精（Goblin Engineer）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN_ENGINEER,
		"地精",
		"功能类",
		"地精",
		"重要工程师，能够修建和修复建筑。比哥布林稍强，有一定自卫能力。",
		150,  # max_health
		8,    # attack_power
		1.5,  # attack_cooldown
		20,   # attack_range
		60,   # pursuit_range
		1,    # armor_value
		1.2,  # body_size
		0.94, # move_speed
		false # is_ranged
	)
	
	# 3. 地精酒保（Goblin Bartender）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN_BARTENDER,
		"地精酒保",
		"功能类",
		"地精",
		"服务单位，主要在安全区域工作。负责酒馆服务和存储管理。",
		120,  # max_health
		6,    # attack_power
		1.8,  # attack_cooldown
		18,   # attack_range
		54,   # pursuit_range
		0,    # armor_value
		1.0,  # body_size
		0.88, # move_speed
		false # is_ranged
	)
	
	# 4. 地精铁匠（Goblin Smith）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN_SMITH,
		"地精铁匠",
		"功能类",
		"地精",
		"专业工匠，负责打造装备和装备存储。需要更高的生存能力和战斗能力。",
		180,  # max_health
		12,   # attack_power
		1.3,  # attack_cooldown
		25,   # attack_range
		75,   # pursuit_range
		2,    # armor_value
		1.5,  # body_size
		0.76, # move_speed
		false # is_ranged
	)
	
	# 战斗类单位（18种）
	
	# 5. 哥布林斥候（Goblin Scout）[远程]
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN_SCOUT,
		"哥布林斥候",
		"战斗类",
		"哥布林",
		"侦察单位，用射程优势避免近战。跟随哨塔巡逻。",
		80,   # max_health
		8,    # attack_power
		1.2,  # attack_cooldown
		120,  # attack_range (远程)
		120,  # pursuit_range (远程=攻击范围)
		0,    # armor_value
		0.8,  # body_size
		1.18, # move_speed
		true  # is_ranged
	)
	
	# 6. 哥布林战士（Goblin Warrior）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_GOBLIN_WARRIOR,
		"哥布林战士",
		"战斗类",
		"哥布林",
		"基础战斗单位，性价比高。守护警戒塔或游荡。",
		200,  # max_health
		15,   # attack_power
		1.5,  # attack_cooldown
		30,   # attack_range
		90,   # pursuit_range
		2,    # armor_value
		1.3,  # body_size
		1.0,  # move_speed
		false # is_ranged
	)
	
	# 7. 兽人（Orc）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC,
		"兽人",
		"战斗类",
		"兽人",
		"基础兵种，拥有良好攻防比。通常游荡。",
		250,  # max_health
		18,   # attack_power
		1.4,  # attack_cooldown
		35,   # attack_range
		105,  # pursuit_range
		3,    # armor_value
		1.8,  # body_size
		0.94, # move_speed
		false # is_ranged
	)
	
	# 8. 兽人打手（Orc Bouncer）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_BOUNCER,
		"兽人打手",
		"战斗类",
		"兽人",
		"保镖单位，高生存和高伤害。守护当前酒馆。",
		350,  # max_health
		22,   # attack_power
		1.3,  # attack_cooldown
		40,   # attack_range
		120,  # pursuit_range
		4,    # armor_value
		2.0,  # body_size
		0.88, # move_speed
		false # is_ranged
	)
	
	# 9. 兽人斥候（Orc Scout）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_SCOUT,
		"兽人斥候",
		"战斗类",
		"兽人",
		"巡逻单位，平衡攻防。在哨塔巡逻。",
		180,  # max_health
		14,   # attack_power
		1.3,  # attack_cooldown
		50,   # attack_range
		150,  # pursuit_range
		2,    # armor_value
		1.5,  # body_size
		1.06, # move_speed
		false # is_ranged
	)
	
	# 10. 兽人猎手（Orc Hunter）[远程]
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_HUNTER,
		"兽人猎手",
		"战斗类",
		"兽人",
		"远程狩猎单位，利用射程。寻找狩猎场进行狩猎。",
		200,  # max_health
		20,   # attack_power
		1.5,  # attack_cooldown
		200,  # attack_range (远程)
		200,  # pursuit_range (远程=攻击范围)
		1,    # armor_value
		1.2,  # body_size
		1.0,  # move_speed
		true  # is_ranged
	)
	
	# 11. 兽人劲弩猎手（Orc Crossbow Hunter）[远程]
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_CROSSBOW_HUNTER,
		"兽人劲弩猎手",
		"战斗类",
		"兽人",
		"精锐远程，更高伤害与射程。寻找狩猎场进行狩猎。",
		220,  # max_health
		28,   # attack_power
		1.8,  # attack_cooldown
		250,  # attack_range (远程)
		250,  # pursuit_range (远程=攻击范围)
		2,    # armor_value
		1.3,  # body_size
		0.94, # move_speed
		true  # is_ranged
	)
	
	# 12. 兽人战士（Orc Warrior）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_WARRIOR,
		"兽人战士",
		"战斗类",
		"兽人",
		"主力近战，高生存。守护警戒塔或游荡。",
		400,  # max_health
		25,   # attack_power
		1.2,  # attack_cooldown
		40,   # attack_range
		120,  # pursuit_range
		5,    # armor_value
		2.2,  # body_size
		0.88, # move_speed
		false # is_ranged
	)
	
	# 13. 兽人重装战士（Orc Heavy Warrior）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_HEAVY_WARRIOR,
		"兽人重装战士",
		"战斗类",
		"兽人",
		"重装甲前排，高承伤。守护警戒塔或游荡。",
		600,  # max_health
		30,   # attack_power
		1.3,  # attack_cooldown
		45,   # attack_range
		135,  # pursuit_range
		8,    # armor_value
		2.5,  # body_size
		0.62, # move_speed
		false # is_ranged
	)
	
	# 14. 兽人角斗士（Orc Gladiator）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_GLADIATOR,
		"兽人角斗士",
		"战斗类",
		"兽人",
		"竞技单位，高攻速。在竞技场战斗或游荡。",
		300,  # max_health
		22,   # attack_power
		1.0,  # attack_cooldown
		35,   # attack_range
		105,  # pursuit_range
		1,    # armor_value
		1.9,  # body_size
		1.06, # move_speed
		false # is_ranged
	)
	
	# 15. 兽人王牌斗士（Orc Elite Gladiator）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_ELITE_GLADIATOR,
		"兽人王牌斗士",
		"战斗类",
		"兽人",
		"精锐角斗士，高输出。在竞技场战斗或游荡。",
		380,  # max_health
		28,   # attack_power
		0.9,  # attack_cooldown
		40,   # attack_range
		120,  # pursuit_range
		2,    # armor_value
		2.0,  # body_size
		1.18, # move_speed
		false # is_ranged
	)
	
	# 16. 兽人冠军（Orc Champion）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_CHAMPION,
		"兽人冠军",
		"战斗类",
		"兽人",
		"终极角斗士，输出生存兼备。在竞技场战斗或游荡。",
		500,  # max_health
		35,   # attack_power
		0.9,  # attack_cooldown
		45,   # attack_range
		135,  # pursuit_range
		4,    # armor_value
		2.3,  # body_size
		1.0,  # move_speed
		false # is_ranged
	)
	
	# 17. 兽人驯兽师（Orc Beastmaster）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_BEASTMASTER,
		"兽人驯兽师",
		"战斗类",
		"兽人",
		"专业单位，配合性高。跟随猎手捕获野兽或在驯兽塔驯服野兽。",
		280,  # max_health
		16,   # attack_power
		1.4,  # attack_cooldown
		50,   # attack_range
		150,  # pursuit_range
		3,    # armor_value
		1.7,  # body_size
		1.0,  # move_speed
		false # is_ranged
	)
	
	# 18. 兽人萨满（Orc Shaman）[魔法]
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_ORC_SHAMAN,
		"兽人萨满",
		"战斗类",
		"兽人",
		"辅助魔法师，治疗与仪式。治疗附近单位或在献祭塔举行仪式。",
		220,  # max_health
		12,   # attack_power
		1.6,  # attack_cooldown
		100,  # attack_range (中远程魔法)
		100,  # pursuit_range (远程=攻击范围)
		2,    # armor_value
		1.4,  # body_size
		0.88, # move_speed
		true  # is_ranged (魔法算作远程)
	)
	
	# 野兽人（召唤单位）（4种）
	
	# 19. 狼人（Werewolf）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_WEREWOLF,
		"狼人",
		"战斗类",
		"野兽人",
		"强力召唤物，高机动高伤害。通常游荡。",
		350,  # max_health
		24,   # attack_power
		1.1,  # attack_cooldown
		35,   # attack_range
		105,  # pursuit_range
		2,    # armor_value
		2.1,  # body_size
		1.26, # move_speed
		false # is_ranged
	)
	
	# 20. 巨魔（Troll）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_TROLL,
		"巨魔",
		"战斗类",
		"野兽人",
		"坦克召唤物，高生存。通常游荡。",
		500,  # max_health
		20,   # attack_power
		1.3,  # attack_cooldown
		40,   # attack_range
		120,  # pursuit_range
		3,    # armor_value
		2.8,  # body_size
		0.76, # move_speed
		false # is_ranged
	)
	
	# 21. 牛头人（Minotaur）
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_MINOTAUR,
		"牛头人",
		"战斗类",
		"野兽人",
		"主力召唤物，高攻高防。通常游荡。",
		450,  # max_health
		32,   # attack_power
		1.5,  # attack_cooldown
		40,   # attack_range
		120,  # pursuit_range
		4,    # armor_value
		2.6,  # body_size
		1.0,  # move_speed
		false # is_ranged
	)
	
	# 22. 半人马（Centaur）[远程]
	_add_unit_data(
		Enums.SpecificEntityType.UNIT_CENTAUR,
		"半人马",
		"战斗类",
		"野兽人",
		"远程召唤物，高机动高输出。通常游荡。",
		320,  # max_health
		26,   # attack_power
		1.3,  # attack_cooldown
		180,  # attack_range (远程)
		180,  # pursuit_range (远程=攻击范围)
		3,    # armor_value
		2.0,  # body_size
		1.18, # move_speed
		true  # is_ranged
	)

## 添加单位数据（完整属性版本）
func _add_unit_data(unit_type: Enums.SpecificEntityType, name: String, category: String, race: String, description: String,
		max_health: int = 100, attack_power: int = 5, attack_cooldown: float = 2.0, attack_range: int = 15,
		pursuit_range: int = 45, armor_value: int = 0, body_size: float = 1.0, move_speed: float = 1.0,
		is_ranged: bool = false) -> void:
	var data = UnitData.new(unit_type, name, category, race, description, max_health, attack_power, attack_cooldown,
			attack_range, pursuit_range, armor_value, body_size, move_speed, is_ranged)
	_unit_data[unit_type] = data

## 获取单位数据
## unit_type: 单位类型
## 返回: UnitData或null
func get_unit_data(unit_type: Enums.SpecificEntityType) -> UnitData:
	return _unit_data.get(unit_type)

## 获取所有单位类型
## 返回: 单位类型数组
func get_all_unit_types() -> Array:
	return _unit_data.keys()

## 按分类获取单位类型
## category: 分类（"功能类"或"战斗类"）
## 返回: 单位类型数组
func get_units_by_category(category: String) -> Array[Enums.SpecificEntityType]:
	var result: Array[Enums.SpecificEntityType] = []
	for unit_type in _unit_data.keys():
		var data = _unit_data[unit_type]
		if data.category == category:
			result.append(unit_type)
	return result

## 按种族获取单位类型
## race: 种族名称
## 返回: 单位类型数组
func get_units_by_race(race: String) -> Array[Enums.SpecificEntityType]:
	var result: Array[Enums.SpecificEntityType] = []
	for unit_type in _unit_data.keys():
		var data = _unit_data[unit_type]
		if data.race == race:
			result.append(unit_type)
	return result

## 搜索单位（按名称）
## search_text: 搜索文本
## 返回: 单位类型数组
func search_units(search_text: String) -> Array[Enums.SpecificEntityType]:
	var result: Array[Enums.SpecificEntityType] = []
	var lower_search = search_text.to_lower()
	
	for unit_type in _unit_data.keys():
		var data = _unit_data[unit_type]
		if data.name.to_lower().contains(lower_search):
			result.append(unit_type)
	
	return result

