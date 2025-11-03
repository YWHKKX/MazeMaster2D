extends Entity
class_name Unit

## 单位基类
## 表示地图上的单位（哥布林、地精等）

var faction: Enums.Faction  # 阵营
var health: int  # 当前生命值
var max_health: int  # 最大生命值
var speed: float  # 移动速度（像素/秒）

## 构造函数
func _init(p_id: int, p_position: Vector2i, p_faction: Enums.Faction, p_max_health: int = 50, p_speed: float = 100.0):
	super._init(p_id, p_position, Enums.EntityType.UNIT)
	faction = p_faction
	max_health = p_max_health
	health = max_health
	speed = p_speed

## 移动到指定位置（网格坐标）
## 注意：这里只设置位置，实际移动逻辑在后续阶段实现
func move_to(new_position: Vector2i) -> void:
	position = new_position

## 获取显示名称
func get_display_name() -> String:
	return "Unit"

## 受到伤害
func take_damage(amount: int) -> void:
	if amount < 0:
		push_warning("Cannot take negative damage: %d" % amount)
		return
	
	health -= amount
	if health < 0:
		health = 0

## 治疗
func heal(amount: int) -> void:
	if amount < 0:
		push_warning("Cannot heal negative amount: %d" % amount)
		return
	
	health += amount
	if health > max_health:
		health = max_health

## 检查是否死亡
func is_dead() -> bool:
	return health <= 0

## 获取生命值百分比
func get_health_percentage() -> float:
	if max_health <= 0:
		return 0.0
	return float(health) / float(max_health)


