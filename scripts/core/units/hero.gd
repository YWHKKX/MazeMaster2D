extends Unit
class_name Hero

## 英雄基类
## 玩家控制或盟友单位类型

## 构造函数
## 默认速度：1瓦块/秒 = 32像素/秒（基准速度）
func _init(p_id: int, p_position: Vector2i, p_faction: Enums.Faction = Enums.Faction.PLAYER, p_max_health: int = 50, p_speed: float = 32.0):
	super._init(p_id, p_position, p_faction, p_max_health, p_speed)
