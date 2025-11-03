extends Unit
class_name Beast

## 野兽基类
## 中立或野性单位类型

## 构造函数
func _init(p_id: int, p_position: Vector2i, p_faction: Enums.Faction = Enums.Faction.NEUTRAL, p_max_health: int = 50, p_speed: float = 100.0):
	super._init(p_id, p_position, p_faction, p_max_health, p_speed)

