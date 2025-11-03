extends BaseManager
class_name TileManager

## 瓦块管理器
## 使用二维数组管理所有瓦块数据（离散网格单元系统）

var _tiles: Array[Array] = []  # 二维数组存储: tiles[x][y] -> Tile
var _width: int = 0
var _height: int = 0

## 初始化
func _initialize() -> void:
	_tiles.clear()
	_width = 0
	_height = 0

## 初始化瓦块数组
## 为每个网格位置创建Tile对象
func InitializeTiles(width: int, height: int, terrain_data: Array[Array] = []) -> void:
	_width = width
	_height = height
	_tiles.clear()
	
	# 初始化二维数组
	for x in range(_width):
		_tiles.append([])
		for y in range(_height):
			var terrain_type: Enums.TerrainType
			
			# 如果提供了地形数据，使用它；否则默认未挖掘
			if terrain_data.size() > x and terrain_data[x].size() > y:
				terrain_type = terrain_data[x][y]
			else:
				terrain_type = Enums.TerrainType.UNDUG
			
			var tile = Tile.new(Vector2i(x, y), terrain_type)
			_tiles[x].append(tile)

## 创建或获取瓦块
func GetOrCreateTile(position: Vector2i, terrain_type: Enums.TerrainType) -> Tile:
	if IsValidPosition(position.x, position.y):
		var tile = _tiles[position.x][position.y]
		if tile.terrain_type != terrain_type:
			tile.set_terrain_type(terrain_type)
		return tile
	return null

## 获取瓦块
## 如果不存在，返回 null
func GetTile(position: Vector2i) -> Tile:
	if IsValidPosition(position.x, position.y):
		return _tiles[position.x][position.y]
	return null

## 更新瓦块地形类型
func UpdateTileTerrain(position: Vector2i, terrain_type: Enums.TerrainType) -> void:
	var tile = GetTile(position)
	if tile:
		tile.set_terrain_type(terrain_type)

## 设置建筑瓦块数据
func SetBuildingTile(position: Vector2i, building_data: BuildingTile) -> void:
	var tile = GetTile(position)
	if tile:
		tile.tile_type = Enums.TileType.BUILDING
		tile.building_data = building_data

## 获取建筑瓦块数据
func GetBuildingTile(position: Vector2i) -> BuildingTile:
	var tile = GetTile(position)
	if tile and tile.tile_type == Enums.TileType.BUILDING:
		return tile.building_data
	return null

## 设置资源瓦块数据
func SetResourceTile(position: Vector2i, resource_data: ResourceTile) -> void:
	var tile = GetTile(position)
	if tile:
		tile.tile_type = Enums.TileType.RESOURCE
		tile.resource_data = resource_data

## 获取资源瓦块数据
func GetResourceTile(position: Vector2i) -> ResourceTile:
	var tile = GetTile(position)
	if tile and tile.tile_type == Enums.TileType.RESOURCE:
		return tile.resource_data
	return null

## 检查位置是否有建筑
func HasBuilding(position: Vector2i) -> bool:
	return GetBuildingTile(position) != null

## 检查位置是否有资源
func HasResource(position: Vector2i) -> bool:
	return GetResourceTile(position) != null

## 检查位置是否可通行
func IsWalkable(position: Vector2i) -> bool:
	var tile = GetTile(position)
	if tile:
		return tile.is_walkable
	return false

## 检查位置是否可建造
func IsBuildable(position: Vector2i) -> bool:
	var tile = GetTile(position)
	if tile:
		return tile.is_buildable
	return false

## 检查位置是否可挖掘
func IsDiggable(position: Vector2i) -> bool:
	var tile = GetTile(position)
	if tile:
		return tile.is_diggable
	return false

## 检查位置是否有效
func IsValidPosition(x: int, y: int) -> bool:
	return x >= 0 and x < _width and y >= 0 and y < _height

## 获取地图宽度
func GetWidth() -> int:
	return _width

## 获取地图高度
func GetHeight() -> int:
	return _height

## 获取所有瓦块（返回二维数组的副本）
func GetAllTiles() -> Array[Array]:
	var result: Array[Array] = []
	for x in range(_width):
		result.append([])
		for y in range(_height):
			result[x].append(_tiles[x][y])
	return result

## 清除所有瓦块
func Clear() -> void:
	_tiles.clear()
	_width = 0
	_height = 0

## ============================================================================
## 网格坐标系统接口
## ============================================================================

var _tile_size: Vector2 = Vector2(32, 32)  # 默认瓦块大小

## 设置瓦块大小（用于坐标转换）
func SetTileSize(tile_size: Vector2) -> void:
	_tile_size = tile_size

## 获取瓦块大小
func GetTileSize() -> Vector2:
	return _tile_size

## 网格坐标转世界坐标（返回瓦块中心）
func GridToWorld(grid_pos: Vector2i) -> Vector2:
	return GridCoordinate.GridToWorld(grid_pos, _tile_size)

## 世界坐标转网格坐标
func WorldToGrid(world_pos: Vector2) -> Vector2i:
	return GridCoordinate.WorldToGrid(world_pos, _tile_size)

## 将世界坐标对齐到网格中心
func SnapToGrid(world_pos: Vector2) -> Vector2:
	return GridCoordinate.SnapToGrid(world_pos, _tile_size)

## 获取相邻网格位置（用于寻路系统）
## @param position: 当前网格位置
## @param include_diagonal: 是否包含对角线方向
## @return: 相邻位置数组
func GetNeighborPositions(position: Vector2i, include_diagonal: bool = false) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions: Array[Vector2i] = [
		Vector2i(-1, 0),  # 左
		Vector2i(1, 0),   # 右
		Vector2i(0, -1),  # 上
		Vector2i(0, 1)    # 下
	]
	
	if include_diagonal:
		directions.append_array([
			Vector2i(-1, -1),  # 左上
			Vector2i(1, -1),   # 右上
			Vector2i(-1, 1),   # 左下
			Vector2i(1, 1)     # 右下
		])
	
	for dir in directions:
		var neighbor_pos = position + dir
		if IsValidPosition(neighbor_pos.x, neighbor_pos.y):
			neighbors.append(neighbor_pos)
	
	return neighbors

## 获取可通行的相邻位置（用于寻路系统）
func GetWalkableNeighbors(position: Vector2i, include_diagonal: bool = false) -> Array[Vector2i]:
	var all_neighbors = GetNeighborPositions(position, include_diagonal)
	var walkable_neighbors: Array[Vector2i] = []
	
	for neighbor_pos in all_neighbors:
		if IsWalkable(neighbor_pos):
			walkable_neighbors.append(neighbor_pos)
	
	return walkable_neighbors

## ============================================================================
## 查找功能接口
## ============================================================================

## 查找最近的资源
## start_pos: 起始位置（网格坐标）
## resource_type: 资源类型（Enums.ResourceType）
## max_range: 最大搜索范围（网格单位，使用曼哈顿距离）
## 返回: 找到的ResourceTile或null（同时返回其位置信息）
func find_nearest_resource(start_pos: Vector2i, resource_type: Enums.ResourceType, max_range: float) -> Dictionary:
	var best_resource: ResourceTile = null
	var best_position: Vector2i = Vector2i(-1, -1)
	var best_distance: float = INF
	
	var max_range_int = int(max_range)
	
	# 在搜索范围内遍历所有瓦块
	for dx in range(-max_range_int, max_range_int + 1):
		for dy in range(-max_range_int, max_range_int + 1):
			var check_pos = start_pos + Vector2i(dx, dy)
			
			# 检查位置是否有效
			if not IsValidPosition(check_pos.x, check_pos.y):
				continue
			
			# 计算曼哈顿距离
			var distance = abs(dx) + abs(dy)
			if distance > max_range:
				continue
			
			# 检查是否有资源
			var resource_tile = GetResourceTile(check_pos)
			if resource_tile == null:
				continue
			
			# 检查资源类型是否匹配
			if resource_tile.resource_type != resource_type:
				continue
			
			# 检查资源是否还有剩余
			if resource_tile.is_depleted():
				continue
			
			# 更新最近资源
			if distance < best_distance:
				best_distance = distance
				best_resource = resource_tile
				best_position = check_pos
	
	if best_resource:
		return {
			"resource": best_resource,
			"position": best_position
		}
	
	return {}

## 查找最近的建筑
## start_pos: 起始位置（网格坐标）
## building_type: 建筑类型字符串（如"DungeonHeart", "Treasury"等）
## max_range: 最大搜索范围（网格单位，使用曼哈顿距离）
## 返回: 找到的BuildingTile及其位置信息，或空Dictionary
func find_nearest_building(start_pos: Vector2i, building_type: String, max_range: float) -> Dictionary:
	var best_building: BuildingTile = null
	var best_position: Vector2i = Vector2i(-1, -1)
	var best_distance: float = INF
	
	var max_range_int = int(max_range)
	
	# 在搜索范围内遍历所有瓦块
	for dx in range(-max_range_int, max_range_int + 1):
		for dy in range(-max_range_int, max_range_int + 1):
			var check_pos = start_pos + Vector2i(dx, dy)
			
			# 检查位置是否有效
			if not IsValidPosition(check_pos.x, check_pos.y):
				continue
			
			# 计算曼哈顿距离
			var distance = abs(dx) + abs(dy)
			if distance > max_range:
				continue
			
			# 检查是否有建筑
			var building_tile = GetBuildingTile(check_pos)
			if building_tile == null:
				continue
			
			# 检查建筑类型是否匹配（通过类名匹配）
			# 支持的类型："DungeonHeart" -> DungeonHeartTile, "Treasury" -> TreasuryTile等
			var matches_type = false
			match building_type:
				"DungeonHeart", "dungeon_heart":
					matches_type = building_tile is DungeonHeartTile
				"Treasury", "treasury":
					# 暂时所有建筑都匹配，后续可以添加TreasuryTile类
					matches_type = true  # 或者 building_tile is TreasuryTile
				_:
					# 默认匹配所有建筑（如果building_type为空或未知）
					matches_type = (building_type == "" or building_type == "Any")
			
			if not matches_type:
				continue
			
			# 检查建筑是否完整（如果已摧毁则忽略）
			if building_tile.is_destroyed():
				continue
			
			# 更新最近建筑
			if distance < best_distance:
				best_distance = distance
				best_building = building_tile
				best_position = check_pos
	
	if best_building:
		return {
			"building": best_building,
			"position": best_position
		}
	
	return {}

