extends Unit
class_name Goblin

## 哥布林单位
## 基础工人单位

## 构造函数
## position: 网格坐标位置
func _init(p_id: int, p_position: Vector2i):
	var faction = Enums.Faction.PLAYER
	var max_health = 50
	var speed = 100.0  # 像素/秒
	super._init(p_id, p_position, faction, max_health, speed)

## 获取显示名称
func get_display_name() -> String:
	return "Goblin"


