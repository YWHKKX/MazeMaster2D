extends Entity
class_name ResourceNode

## 资源节点基类
## 表示地图上的资源点（金矿、魔力水晶等）

var resource_type: Enums.ResourceType  # 资源类型
var capacity: int  # 总容量
var current_amount: int  # 当前资源数量

## 构造函数
func _init(p_id: int, p_position: Vector2i, p_resource_type: Enums.ResourceType, p_capacity: int):
	super._init(p_id, p_position, Enums.EntityType.RESOURCE)
	resource_type = p_resource_type
	capacity = p_capacity
	current_amount = capacity  # 初始时资源是满的

## 提取资源
## amount: 要提取的数量
## 返回：实际提取的数量（如果资源不足，只提取可用数量）
func extract_resource(amount: int) -> int:
	if amount < 0:
		push_warning("Cannot extract negative amount: %d" % amount)
		return 0
	
	var actual_extract = min(amount, current_amount)
	current_amount -= actual_extract
	return actual_extract

## 检查是否有资源
func has_resource(amount: int = 1) -> bool:
	return current_amount >= amount

## 检查是否已耗尽
func is_depleted() -> bool:
	return current_amount <= 0

## 获取剩余资源百分比
func get_resource_percentage() -> float:
	if capacity <= 0:
		return 0.0
	return float(current_amount) / float(capacity)


