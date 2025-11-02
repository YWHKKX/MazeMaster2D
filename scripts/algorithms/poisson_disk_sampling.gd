extends RefCounted
class_name PoissonDiskSampling

## 泊松圆盘分布算法
## 实现 Bridson's algorithm，使用网格加速优化性能

var _grid: Dictionary = {}  # 网格加速结构
var _cell_size: float = 0.0

## 生成点集
## min_distance: 点之间的最小距离
## num_attempts: 每个点的最大尝试次数
## bounds: 采样范围 (Rect2i)
func GeneratePoints(
	min_distance: float, 
	num_attempts: int, 
	bounds: Rect2i
) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	_grid.clear()
	_cell_size = min_distance / sqrt(2.0)
	
	# 如果没有活动点列表，先添加一个随机点
	if points.is_empty():
		var initial_point = _random_point_in_bounds(bounds)
		points.append(initial_point)
		_add_to_grid(initial_point)
	
	# 活动点列表
	var active_list: Array[Vector2i] = [points[0]]
	
	# 主循环
	while not active_list.is_empty():
		# 随机选择一个活动点
		var index = randi() % active_list.size()
		var current_point = active_list[index]
		var found = false
		
		# 尝试生成新点
		for attempt in range(num_attempts):
			var new_point_variant = _generate_annulus_point(current_point, min_distance, bounds)
			
			if new_point_variant != null and new_point_variant is Vector2i:
				var new_point: Vector2i = new_point_variant
				if _is_valid_point(new_point, points, min_distance, bounds):
					points.append(new_point)
					active_list.append(new_point)
					_add_to_grid(new_point)
					found = true
					break
		
		# 如果没有找到新点，从活动列表中移除
		if not found:
			active_list.remove_at(index)
	
	return points

## 在环形区域内生成随机点
## 返回 Variant (Vector2i 或 null)
func _generate_annulus_point(center: Vector2i, min_dist: float, bounds: Rect2i) -> Variant:
	var angle = randf() * TAU
	var distance = min_dist + randf() * min_dist  # 在 min_dist 到 2*min_dist 之间
	
	var offset = Vector2(
		cos(angle) * distance,
		sin(angle) * distance
	)
	
	var new_point = Vector2i(center.x + int(offset.x), center.y + int(offset.y))
	
	# 检查边界
	if bounds.has_point(new_point):
		return new_point
	return null

## 验证点是否有效
func _is_valid_point(
	point: Vector2i, 
	existing_points: Array[Vector2i], 
	min_distance: float,
	bounds: Rect2i
) -> bool:
	if not bounds.has_point(point):
		return false
	
	# 检查网格中的邻居
	var grid_pos = _point_to_grid(point)
	var neighbors = [
		grid_pos + Vector2i(-1, -1), grid_pos + Vector2i(0, -1), grid_pos + Vector2i(1, -1),
		grid_pos + Vector2i(-1, 0),  grid_pos,                  grid_pos + Vector2i(1, 0),
		grid_pos + Vector2i(-1, 1),  grid_pos + Vector2i(0, 1), grid_pos + Vector2i(1, 1)
	]
	
	for neighbor_grid in neighbors:
		if _grid.has(neighbor_grid):
			var neighbor_points = _grid[neighbor_grid]
			for neighbor_point in neighbor_points:
				var dist = point.distance_to(neighbor_point)
				if dist < min_distance:
					return false
	
	return true

## 将点添加到网格
func _add_to_grid(point: Vector2i) -> void:
	var grid_pos = _point_to_grid(point)
	if not _grid.has(grid_pos):
		_grid[grid_pos] = []
	_grid[grid_pos].append(point)

## 将世界坐标转换为网格坐标
func _point_to_grid(point: Vector2i) -> Vector2i:
	return Vector2i(
		int(point.x / _cell_size),
		int(point.y / _cell_size)
	)

## 在边界内生成随机点
func _random_point_in_bounds(bounds: Rect2i) -> Vector2i:
	return Vector2i(
		bounds.position.x + randi() % bounds.size.x,
		bounds.position.y + randi() % bounds.size.y
	)
