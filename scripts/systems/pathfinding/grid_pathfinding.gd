extends RefCounted
class_name GridPathfinding

## 网格寻路接口
## 使用AStarGrid2D和A*算法进行寻路
## 策略：优先使用AStarGrid2D移动到目标瓦块，再使用A*进行精确移动

var _tile_manager: TileManager
var _astar_grid: AStarGrid2D

## 初始化
func _init(tile_mgr: TileManager):
	_tile_manager = tile_mgr

## 初始化AStarGrid2D（延迟初始化）
func _initialize_astar_grid() -> void:
	if _astar_grid:
		return  # 已经初始化过了
	
	var width = _tile_manager.GetWidth()
	var height = _tile_manager.GetHeight()
	
	# 如果大小为0，表示TileManager还没有初始化，跳过
	if width == 0 or height == 0:
		return
	
	# 创建AStarGrid2D实例
	_astar_grid = AStarGrid2D.new()
	_astar_grid.size = Vector2i(width, height)
	_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER  # 只允许四方向移动
	_astar_grid.update()
	
	# 根据TileManager的通行性数据更新网格
	_update_astar_grid_walkability()

## 更新AStarGrid2D的通行性数据
func _update_astar_grid_walkability() -> void:
	# 确保已经初始化
	_initialize_astar_grid()
	
	if not _astar_grid:
		return
	
	var width = _tile_manager.GetWidth()
	var height = _tile_manager.GetHeight()
	
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var is_walkable = _tile_manager.IsWalkable(pos)
			_astar_grid.set_point_solid(pos, not is_walkable)

## 计算路径（使用AStarGrid2D）
## @param start: 起点（网格坐标）
## @param end: 终点（网格坐标）
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
func find_path_astar_grid(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	if start == end:
		return [start]
	
	# 确保已经初始化
	_initialize_astar_grid()
	if not _astar_grid:
		return []
	
	# 检查起点和终点是否可通行
	if not _tile_manager.IsWalkable(start) or not _tile_manager.IsWalkable(end):
		return []
	
	# 使用AStarGrid2D计算路径
	var point_path = _astar_grid.get_point_path(start, end)
	
	# 转换为Vector2i数组
	var path: Array[Vector2i] = []
	for point in point_path:
		path.append(Vector2i(point.x, point.y))
	
	return path

## 计算路径（使用A*算法进行精确寻路）
## @param start: 起点（网格坐标）
## @param end: 终点（网格坐标）
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
func find_path_astar(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# 创建检查函数
	var is_walkable_func = func(pos: Vector2i) -> bool:
		return _tile_manager.IsWalkable(pos)
	
	var get_neighbors_func = func(pos: Vector2i) -> Array[Vector2i]:
		return _tile_manager.GetWalkableNeighbors(pos, false)
	
	# 使用A*算法
	return AStarPathfinding.find_path(
		start,
		end,
		is_walkable_func,
		get_neighbors_func
	)

## 计算路径（混合策略：优先AStarGrid2D，精确移动使用A*）
## @param start: 起点（网格坐标）
## @param end: 终点（网格坐标）
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
func find_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# 优先使用AStarGrid2D进行快速寻路
	var path = find_path_astar_grid(start, end)
	
	# 如果AStarGrid2D找到路径，返回它（足够精确）
	if not path.is_empty():
		return path
	
	# 如果AStarGrid2D失败，使用A*算法作为后备
	path = find_path_astar(start, end)
	
	return path

## 更新网格通行性（当地形改变时调用）
func update_walkability() -> void:
	_update_astar_grid_walkability()

