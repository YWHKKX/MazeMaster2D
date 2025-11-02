extends Node2D
class_name TerrainRenderer

## 地形渲染器
## 使用 ColorRect 渲染每个瓦块

var _terrain_manager: TerrainManager
var _tile_size: Vector2 = Vector2(32, 32)  # 每个瓦块的像素大小
var _tile_rects: Array[ColorRect] = []

## 初始化
func setup(terrain_mgr: TerrainManager, tile_size: Vector2 = Vector2(32, 32)) -> void:
	_terrain_manager = terrain_mgr
	_tile_size = tile_size

## 渲染地形
func render_terrain() -> void:
	_clear_tiles()
	
	if not _terrain_manager or not _terrain_manager.is_initialized():
		return
	
	var width = _terrain_manager.GetWidth()
	var height = _terrain_manager.GetHeight()
	
	for x in range(width):
		for y in range(height):
			var terrain_type = _terrain_manager.GetTerrainType(x, y)
			var world_pos = Vector2(x * _tile_size.x, y * _tile_size.y)
			_create_tile(world_pos, terrain_type)

## 创建瓦块
func _create_tile(position: Vector2, terrain_type: Enums.TerrainType) -> void:
	var rect = ColorRect.new()
	rect.size = _tile_size
	rect.position = position
	rect.color = _get_terrain_color(terrain_type)
	add_child(rect)
	_tile_rects.append(rect)

## 获取地形颜色
func _get_terrain_color(terrain_type: Enums.TerrainType) -> Color:
	match terrain_type:
		Enums.TerrainType.UNDUG:
			return Color.BLACK
		Enums.TerrainType.DUG:
			return Color.GRAY
		Enums.TerrainType.WALL:
			return Color.DARK_GRAY
		_:
			return Color.BLACK

## 清除所有瓦块
func _clear_tiles() -> void:
	for rect in _tile_rects:
		if is_instance_valid(rect):
			rect.queue_free()
	_tile_rects.clear()

