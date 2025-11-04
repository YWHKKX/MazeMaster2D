extends ResourceTile
class_name GoldMineTile

## 金矿瓦块
## 生成金币的资源瓦块类型

## 构造函数
func _init():
	var capacity = 1000  # 金矿容量
	super._init(Enums.ResourceType.GOLD, capacity)

