extends RefCounted
class_name AStarPathfinding

## A*寻路算法实现
## 用于精确寻路（在AStarGrid2D之后进行精确移动）

## 节点数据结构
class AStarNode:
	var position: Vector2i
	var g_cost: float = 0.0  # 从起点到当前节点的实际代价
	var h_cost: float = 0.0  # 从当前节点到终点的启发式估计
	var parent: AStarNode = null
	
	func _init(p_position: Vector2i):
		position = p_position
	
	func get_f_cost() -> float:
		return g_cost + h_cost

## 计算曼哈顿距离（启发式函数）
static func manhattan_distance(from: Vector2i, to: Vector2i) -> float:
	return abs(from.x - to.x) + abs(from.y - to.y)

## A*寻路主函数
## @param start: 起点位置（网格坐标）
## @param end: 终点位置（网格坐标）
## @param is_walkable_func: 函数，接收Vector2i返回bool，检查位置是否可通行
## @param get_neighbors_func: 函数，接收Vector2i返回Array[Vector2i]，获取相邻位置
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
static func find_path(
	start: Vector2i,
	end: Vector2i,
	is_walkable_func: Callable,
	get_neighbors_func: Callable
) -> Array[Vector2i]:
	if start == end:
		return [start]
	
	# 检查起点和终点是否可通行
	if not is_walkable_func.call(start):
		return []
	if not is_walkable_func.call(end):
		return []
	
	var open_set: Array[AStarNode] = []
	var closed_set: Dictionary = {}  # 使用字典快速查找
	
	# 创建起点节点
	var start_node = AStarNode.new(start)
	start_node.h_cost = manhattan_distance(start, end)
	open_set.append(start_node)
	
	# 主循环
	while not open_set.is_empty():
		# 找到F值最小的节点
		var current_node = open_set[0]
		var current_index = 0
		for i in range(1, open_set.size()):
			if open_set[i].get_f_cost() < current_node.get_f_cost() or \
			   (open_set[i].get_f_cost() == current_node.get_f_cost() and \
			    open_set[i].h_cost < current_node.h_cost):
				current_node = open_set[i]
				current_index = i
		
		# 从开放列表中移除当前节点
		open_set.remove_at(current_index)
		
		# 添加到关闭列表
		closed_set[current_node.position] = current_node
		
		# 检查是否到达终点
		if current_node.position == end:
			return reconstruct_path(current_node)
		
		# 处理相邻节点
		var neighbors = get_neighbors_func.call(current_node.position) as Array[Vector2i]
		for neighbor_pos in neighbors:
			# 检查是否可通行
			if not is_walkable_func.call(neighbor_pos):
				continue
			
			# 如果已经在关闭列表中，跳过
			if closed_set.has(neighbor_pos):
				continue
			
			# 计算从起点到相邻节点的代价（假设移动代价为1）
			var move_cost = 1.0
			var new_g_cost = current_node.g_cost + move_cost
			
			# 检查相邻节点是否在开放列表中
			var neighbor_node: AStarNode = null
			for node in open_set:
				if node.position == neighbor_pos:
					neighbor_node = node
					break
			
			# 如果不在开放列表中，创建新节点
			if neighbor_node == null:
				neighbor_node = AStarNode.new(neighbor_pos)
				neighbor_node.h_cost = manhattan_distance(neighbor_pos, end)
				open_set.append(neighbor_node)
			
			# 如果找到更短的路径，更新节点
			if new_g_cost < neighbor_node.g_cost:
				neighbor_node.parent = current_node
				neighbor_node.g_cost = new_g_cost
			
			# 重新排序开放列表（简单实现，可以优化）
			open_set.sort_custom(func(a, b): return a.get_f_cost() < b.get_f_cost())
	
	# 无法找到路径
	return []

## 重构路径
static func reconstruct_path(end_node: AStarNode) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current: AStarNode = end_node
	
	while current != null:
		path.insert(0, current.position)
		current = current.parent
	
	return path

