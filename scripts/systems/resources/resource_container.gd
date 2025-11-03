extends RefCounted
class_name ResourceContainer

## 资源容器
## 存储和管理资源（金币、魔力、食物等）

var _resources: Dictionary = {}

## 构造函数
func _init():
	# 初始化所有资源类型为0
	for resource_type in Enums.ResourceType.values():
		_resources[resource_type] = 0

## 添加资源
func add_resource(resource_type: Enums.ResourceType, amount: int) -> void:
	if amount < 0:
		push_warning("Cannot add negative amount: %d" % amount)
		return
	
	if not _resources.has(resource_type):
		_resources[resource_type] = 0
	
	_resources[resource_type] += amount

## 移除资源
## 返回：实际移除的数量（如果资源不足，只移除可用数量）
func remove_resource(resource_type: Enums.ResourceType, amount: int) -> int:
	if amount < 0:
		push_warning("Cannot remove negative amount: %d" % amount)
		return 0
	
	if not _resources.has(resource_type):
		return 0
	
	var current = _resources[resource_type]
	var actual_remove = min(amount, current)
	_resources[resource_type] -= actual_remove
	
	return actual_remove

## 获取资源数量
func get_resource(resource_type: Enums.ResourceType) -> int:
	return _resources.get(resource_type, 0)

## 检查是否有资源
func has_resource(resource_type: Enums.ResourceType, amount: int = 1) -> bool:
	return get_resource(resource_type) >= amount

## 检查是否能够支付（有足够的资源）
func can_afford(resources: Dictionary) -> bool:
	for resource_type in resources:
		var required = resources[resource_type]
		if not has_resource(resource_type, required):
			return false
	return true

## 支付资源（如果可以支付）
## 返回：是否成功支付
func pay_resources(resources: Dictionary) -> bool:
	if not can_afford(resources):
		return false
	
	for resource_type in resources:
		var amount = resources[resource_type]
		remove_resource(resource_type, amount)
	
	return true

## 获取所有资源
func get_all_resources() -> Dictionary:
	return _resources.duplicate()

## 清空所有资源
func clear() -> void:
	_resources.clear()
	for resource_type in Enums.ResourceType.values():
		_resources[resource_type] = 0


