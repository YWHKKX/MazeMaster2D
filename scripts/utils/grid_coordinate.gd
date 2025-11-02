extends RefCounted
class_name GridCoordinate

## 网格坐标系统工具类
## 提供网格坐标与世界坐标的转换、对齐等功能

## 网格坐标转世界坐标（返回瓦块中心）
## @param grid_pos: 网格坐标 (Vector2i)
## @param tile_size: 瓦块大小 (Vector2)
## @return: 世界坐标 (Vector2)，瓦块中心位置
static func GridToWorld(grid_pos: Vector2i, tile_size: Vector2) -> Vector2:
	return Vector2(
		grid_pos.x * tile_size.x + tile_size.x / 2.0,
		grid_pos.y * tile_size.y + tile_size.y / 2.0
	)

## 世界坐标转网格坐标
## @param world_pos: 世界坐标 (Vector2)
## @param tile_size: 瓦块大小 (Vector2)
## @return: 网格坐标 (Vector2i)
static func WorldToGrid(world_pos: Vector2, tile_size: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / tile_size.x)),
		int(floor(world_pos.y / tile_size.y))
	)

## 将世界坐标对齐到网格中心
## @param world_pos: 世界坐标 (Vector2)
## @param tile_size: 瓦块大小 (Vector2)
## @return: 对齐后的世界坐标 (Vector2)，对齐到瓦块中心
static func SnapToGrid(world_pos: Vector2, tile_size: Vector2) -> Vector2:
	var grid_pos = WorldToGrid(world_pos, tile_size)
	return GridToWorld(grid_pos, tile_size)

## 验证网格位置是否有效
## @param grid_pos: 网格坐标 (Vector2i)
## @param width: 地图宽度
## @param height: 地图高度
## @return: 是否有效
static func IsValidGridPosition(grid_pos: Vector2i, width: int, height: int) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < width and grid_pos.y >= 0 and grid_pos.y < height

