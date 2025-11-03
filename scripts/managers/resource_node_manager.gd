extends BaseManager
class_name ResourceNodeManager

## 资源节点管理器
## 管理所有地图上的资源节点

var _nodes: Array[ResourceNode] = []

## 初始化管理器
func _initialize() -> void:
	_nodes.clear()

## 清理管理器
func _cleanup() -> void:
	_nodes.clear()

## 注册资源节点
func register_node(node: ResourceNode) -> void:
	if _nodes.has(node):
		push_warning("Resource node already registered")
		return
	_nodes.append(node)

## 移除资源节点
func remove_node(node: ResourceNode) -> void:
	var index = _nodes.find(node)
	if index >= 0:
		_nodes.remove_at(index)

## 获取所有资源节点
func get_all_nodes() -> Array[ResourceNode]:
	return _nodes.duplicate()

## 根据资源类型获取节点
func get_nodes_by_type(resource_type: Enums.ResourceType) -> Array[ResourceNode]:
	var result: Array[ResourceNode] = []
	for node in _nodes:
		if node.resource_type == resource_type:
			result.append(node)
	return result

## 查找最近的资源节点
## position: 网格坐标位置
## resource_type: 资源类型（可选，null表示任意类型）
func find_nearest_node(position: Vector2i, resource_type: Enums.ResourceType = -1) -> ResourceNode:
	var nearest: ResourceNode = null
	var nearest_distance: float = INF
	
	for node in _nodes:
		# 如果指定了资源类型，只考虑匹配的节点
		if resource_type >= 0 and node.resource_type != resource_type:
			continue
		
		# 如果节点已耗尽，跳过
		if node.is_depleted():
			continue
		
		# 计算距离
		var distance = position.distance_to(node.position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node
	
	return nearest

## 获取指定位置的资源节点
func get_node_at_position(position: Vector2i) -> ResourceNode:
	for node in _nodes:
		if node.position == position:
			return node
	return null


