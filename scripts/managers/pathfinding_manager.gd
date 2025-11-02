extends BaseManager
class_name PathfindingManager

## 寻路管理器
## 管理寻路系统，提供统一的寻路接口和路径缓存

var _grid_pathfinding: GridPathfinding
var _tile_manager: TileManager

# 路径缓存（可选优化）
var _path_cache: Dictionary = {}  # key: "x1,y1->x2,y2", value: Array[Vector2i]
var _cache_enabled: bool = false

## 初始化
func _initialize() -> void:
	_path_cache.clear()

## 设置寻路系统
## @param tile_mgr: TileManager实例
func setup(tile_mgr: TileManager) -> void:
	_tile_manager = tile_mgr
	_grid_pathfinding = GridPathfinding.new(tile_mgr)

## 计算路径
## @param start: 起点（网格坐标）
## @param end: 终点（网格坐标）
## @param use_dfs_fallback: 是否在失败时使用DFS后备
## @return: 路径数组（Vector2i数组），如果无法到达则返回空数组
func find_path(start: Vector2i, end: Vector2i, use_dfs_fallback: bool = true) -> Array[Vector2i]:
	if not _grid_pathfinding:
		push_warning("PathfindingManager not setup. Call setup() first.")
		return []
	
	# 检查缓存
	if _cache_enabled:
		var cache_key = "%d,%d->%d,%d" % [start.x, start.y, end.x, end.y]
		if _path_cache.has(cache_key):
			return _path_cache[cache_key].duplicate()
	
	# 计算路径
	var path = _grid_pathfinding.find_path(start, end)
	
	# 如果路径为空且允许使用DFS后备
	if path.is_empty() and use_dfs_fallback:
		path = _find_path_with_dfs(start, end)
	
	# 缓存路径
	if _cache_enabled and not path.is_empty():
		var cache_key = "%d,%d->%d,%d" % [start.x, start.y, end.x, end.y]
		_path_cache[cache_key] = path.duplicate()
	
	return path

## 使用DFS后备算法寻路
func _find_path_with_dfs(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var is_walkable_func = func(pos: Vector2i) -> bool:
		return _tile_manager.IsWalkable(pos)
	
	var get_neighbors_func = func(pos: Vector2i) -> Array[Vector2i]:
		return _tile_manager.GetWalkableNeighbors(pos, false)
	
	return DFSPathfinding.find_path(
		start,
		end,
		is_walkable_func,
		get_neighbors_func
	)

## 清除路径缓存
func clear_cache() -> void:
	_path_cache.clear()

## 启用/禁用路径缓存
func set_cache_enabled(enabled: bool) -> void:
	_cache_enabled = enabled
	if not enabled:
		clear_cache()

## 更新网格通行性（当地形改变时调用）
func update_walkability() -> void:
	if _grid_pathfinding:
		_grid_pathfinding.update_walkability()
		clear_cache()  # 清除缓存，因为地形改变了

