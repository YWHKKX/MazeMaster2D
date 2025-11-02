extends BaseManager
class_name TerrainManager

## 地形管理器
## 使用二维数组管理地图地形数据（200x200网格）

var _terrain_data: Array[Array] = []
var _width: int = 200
var _height: int = 200

## 初始化地形
func _initialize() -> void:
	InitializeTerrain(_width, _height, Enums.TerrainType.UNDUG)

## 初始化地形数据
func InitializeTerrain(width: int, height: int, default_type: Enums.TerrainType) -> void:
	_width = width
	_height = height
	_terrain_data.clear()
	
	for x in range(_width):
		var row: Array = []
		for y in range(_height):
			row.append(default_type)
		_terrain_data.append(row)

## 设置地形类型
## @param notify_tile_manager: 是否通知TileManager更新（如果已初始化）
func SetTerrainType(x: int, y: int, type: Enums.TerrainType, notify_tile_manager: bool = false) -> bool:
	if not IsValidPosition(x, y):
		push_warning("Invalid position: (%d, %d)" % [x, y])
		return false
	
	_terrain_data[x][y] = type
	
	# 如果启用了通知且TileManager已初始化，同步更新
	if notify_tile_manager:
		_NotifyTileManager(x, y, type)
	
	return true

## 通知TileManager更新瓦块（私有方法）
func _NotifyTileManager(x: int, y: int, type: Enums.TerrainType) -> void:
	# 注意：这里不直接引用TileManager避免循环依赖
	# TileManager应该在初始化时使用GetTerrainData()获取数据
	pass

## 获取地形类型
func GetTerrainType(x: int, y: int) -> Enums.TerrainType:
	if not IsValidPosition(x, y):
		push_warning("Invalid position: (%d, %d)" % [x, y])
		return Enums.TerrainType.UNDUG
	
	return _terrain_data[x][y]

## 批量挖掘地形
func DigTerrain(start_pos: Vector2i, end_pos: Vector2i, target_type: Enums.TerrainType) -> void:
	var min_x = min(start_pos.x, end_pos.x)
	var max_x = max(start_pos.x, end_pos.x)
	var min_y = min(start_pos.y, end_pos.y)
	var max_y = max(start_pos.y, end_pos.y)
	
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			if IsValidPosition(x, y):
				SetTerrainType(x, y, target_type)

## 检查位置是否有效
func IsValidPosition(x: int, y: int) -> bool:
	return x >= 0 and x < _width and y >= 0 and y < _height

## 获取地图宽度
func GetWidth() -> int:
	return _width

## 获取地图高度
func GetHeight() -> int:
	return _height

## 获取所有地形数据（用于调试）
func GetTerrainData() -> Array[Array]:
	return _terrain_data

