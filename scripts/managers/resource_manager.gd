extends BaseManager
class_name ResourceManager

## 资源管理器
## 全局资源存储（玩家资源）

var _resources: ResourceContainer

## 初始化管理器
func _initialize() -> void:
	_resources = ResourceContainer.new()
	# 初始资源（可选：用于测试）
	# _resources.add_resource(Enums.ResourceType.GOLD, 1000)

## 清理管理器
func _cleanup() -> void:
	_resources = null

## 添加金币
func add_gold(amount: int) -> void:
	_resources.add_resource(Enums.ResourceType.GOLD, amount)

## 添加魔力
func add_mana(amount: int) -> void:
	_resources.add_resource(Enums.ResourceType.MANA, amount)

## 添加食物
func add_food(amount: int) -> void:
	_resources.add_resource(Enums.ResourceType.FOOD, amount)

## 移除金币
func remove_gold(amount: int) -> int:
	return _resources.remove_resource(Enums.ResourceType.GOLD, amount)

## 移除魔力
func remove_mana(amount: int) -> int:
	return _resources.remove_resource(Enums.ResourceType.MANA, amount)

## 移除食物
func remove_food(amount: int) -> int:
	return _resources.remove_resource(Enums.ResourceType.FOOD, amount)

## 获取金币
func get_gold() -> int:
	return _resources.get_resource(Enums.ResourceType.GOLD)

## 获取魔力
func get_mana() -> int:
	return _resources.get_resource(Enums.ResourceType.MANA)

## 获取食物
func get_food() -> int:
	return _resources.get_resource(Enums.ResourceType.FOOD)

## 获取所有资源
func get_total_resources() -> Dictionary:
	return _resources.get_all_resources()

## 获取资源容器（用于直接操作）
func get_resource_container() -> ResourceContainer:
	return _resources

## 检查是否可以支付
func can_afford(resources: Dictionary) -> bool:
	return _resources.can_afford(resources)

## 支付资源
func pay_resources(resources: Dictionary) -> bool:
	return _resources.pay_resources(resources)


