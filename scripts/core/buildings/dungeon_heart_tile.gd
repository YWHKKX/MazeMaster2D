extends BuildingTile
class_name DungeonHeartTile

## 地牢之心瓦块
## 主基地建筑，可以存储资源

var _resource_container: ResourceContainer

## 构造函数
func _init():
	var building_size = Vector2i(3, 3)  # 地牢之心大小
	var building_max_health = 500  # 生命值
	super._init(building_size, building_max_health)
	
	# 创建资源容器（用于存储资源）
	_resource_container = ResourceContainer.new()

## 获取资源容器
func get_resource_container() -> ResourceContainer:
	return _resource_container

## 添加资源到地牢之心
func add_resource(resource_type: Enums.ResourceType, amount: int) -> void:
	_resource_container.add_resource(resource_type, amount)

## 从地牢之心提取资源
func extract_resource(resource_type: Enums.ResourceType, amount: int) -> int:
	return _resource_container.remove_resource(resource_type, amount)

## 获取资源数量
func get_resource(resource_type: Enums.ResourceType) -> int:
	return _resource_container.get_resource(resource_type)

