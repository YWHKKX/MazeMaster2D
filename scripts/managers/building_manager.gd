extends BaseManager
class_name BuildingManager

## 建筑管理器
## 管理所有地图上的建筑

var _buildings: Array[Building] = []

## 初始化管理器
func _initialize() -> void:
	_buildings.clear()

## 清理管理器
func _cleanup() -> void:
	_buildings.clear()

## 注册建筑
func register_building(building: Building) -> void:
	if _buildings.has(building):
		push_warning("Building already registered")
		return
	_buildings.append(building)

## 移除建筑
func remove_building(building: Building) -> void:
	var index = _buildings.find(building)
	if index >= 0:
		_buildings.remove_at(index)

## 获取所有建筑
func get_all_buildings() -> Array[Building]:
	return _buildings.duplicate()

## 获取指定位置的建筑
func get_building_at_position(position: Vector2i) -> Building:
	for building in _buildings:
		if building.contains_position(position):
			return building
	return null

## 检查指定位置是否可以放置建筑
## position: 建筑左上角位置
## size: 建筑大小
## tile_manager: TileManager（用于检查地形）
## entity_manager: EntityManager（用于检查实体冲突）
func can_place_building(position: Vector2i, size: Vector2i, tile_manager: TileManager, entity_manager: EntityManager) -> bool:
	# 检查边界
	if not tile_manager:
		return false
	
	# 检查所有占用的格子
	for x in range(size.x):
		for y in range(size.y):
			var grid_pos = position + Vector2i(x, y)
			
			# 检查是否在地图范围内
			if not tile_manager.IsValidPosition(grid_pos.x, grid_pos.y):
				return false
			
			# 检查地形是否可建造
			var tile = tile_manager.GetTile(grid_pos)
			if not tile or not tile.is_buildable:
				return false
			
			# 检查是否有其他实体
			if entity_manager and entity_manager.has_entity_at_position(grid_pos):
				return false
	
	return true
