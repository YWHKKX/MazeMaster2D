extends ResourceTile
class_name MeatGrubNestTile

## 肉虫穴瓦块
## 生成食物的资源瓦块类型

## 构造函数
func _init():
	var capacity = 600  # 肉虫穴容量
	super._init(Enums.ResourceType.FOOD, capacity)

