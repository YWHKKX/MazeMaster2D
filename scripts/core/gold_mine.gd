extends ResourceNode
class_name GoldMine

## 金矿
## 生成金币的资源节点

## 构造函数
## position: 网格坐标位置
func _init(p_id: int, p_position: Vector2i):
	var capacity = 1000  # 金矿容量
	super._init(p_id, p_position, Enums.ResourceType.GOLD, capacity)


