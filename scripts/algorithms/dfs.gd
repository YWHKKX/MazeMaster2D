extends RefCounted
class_name DFSPathfinding

## DFS（深度优先搜索）后备寻路算法
## 当A*算法失败时使用，尝试找到任何可达路径（可能不是最优）

## DFS寻路主函数
## @param start: 起点位置（网格坐标）
## @param end: 终点位置（网格坐标）
## @param is_walkable_func: 函数，接收Vector2i返回bool，检查位置是否可通行
## @param get_neighbors_func: 函数，接收Vector2i返回Array[Vector2i]，获取相邻位置
## @param max_depth: 最大搜索深度（防止无限递归）
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
static func find_path(
	start: Vector2i,
	end: Vector2i,
	is_walkable_func: Callable,
	get_neighbors_func: Callable,
	max_depth: int = 10000
) -> Array[Vector2i]:
	if start == end:
		return [start]
	
	# 检查起点和终点是否可通行
	if not is_walkable_func.call(start):
		return []
	if not is_walkable_func.call(end):
		return []
	
	# 使用栈进行深度优先搜索
	var visited: Dictionary = {}
	var stack: Array[Dictionary] = []
	
	# 初始状态：起点
	stack.append({
		"position": start,
		"path": [start]
	})
	visited[start] = true
	
	# 主循环
	while not stack.is_empty():
		# 防止栈溢出
		if stack.size() > max_depth:
			break
		
		var current = stack.pop_back()
		var current_pos = current.position as Vector2i
		var current_path = current.path as Array[Vector2i]
		
		# 检查是否到达终点
		if current_pos == end:
			return current_path
		
		# 获取相邻位置
		var neighbors = get_neighbors_func.call(current_pos) as Array[Vector2i]
		
		# 处理每个相邻位置
		for neighbor_pos in neighbors:
			# 检查是否已访问
			if visited.has(neighbor_pos):
				continue
			
			# 检查是否可通行
			if not is_walkable_func.call(neighbor_pos):
				continue
			
			# 标记为已访问
			visited[neighbor_pos] = true
			
			# 创建新路径
			var new_path = current_path.duplicate()
			new_path.append(neighbor_pos)
			
			# 添加到栈中
			stack.append({
				"position": neighbor_pos,
				"path": new_path
			})
	
	# 无法找到路径
	return []

