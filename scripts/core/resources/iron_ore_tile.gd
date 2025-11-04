extends ResourceTile
class_name IronOreTile

## 铁矿瓦块
## 生成铁矿的资源瓦块类型

## 构造函数
func _init():
	var capacity = 800  # 铁矿容量
	super._init(Enums.ResourceType.IRON, capacity)

