extends Hero
class_name Goblin

## 哥布林单位
## 基础工人单位，继承自Hero

## 最大金币存量
const MAX_GOLD_CAPACITY: int = 60

## 构造函数
## position: 网格坐标位置
func _init(p_id: int, p_position: Vector2i):
	var unit_faction = Enums.Faction.PLAYER
	var unit_max_health = 50
	# 基准速度：1瓦块/秒 = 1秒/瓦块，转换为像素/秒：1 * 32 = 32像素/秒
	var unit_speed = 32.0 # 像素/秒（对应1瓦块/秒，基准速度）
	super._init(p_id, p_position, unit_faction, unit_max_health, unit_speed)

## 获取显示名称
func get_display_name() -> String:
	return "Goblin"
	
## 获取最大金币存量
func get_max_gold_capacity() -> int:
	return MAX_GOLD_CAPACITY
