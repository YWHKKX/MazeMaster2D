extends TileMap
class_name TerrainRenderer

## 地形渲染器 - 使用 TileMap 渲染
## 需要在场景中配置 TileSet 资源

var _terrain_manager: TerrainManager
var _tile_size: Vector2i = Vector2i(32, 32)

# 瓦块 ID（对应 TileSet 中的索引）
const TILE_UNDUG = 0
const TILE_DUG = 1
const TILE_WALL = 2

func setup(terrain_mgr: TerrainManager, tile_size: Vector2 = Vector2(32, 32)) -> void:
	_terrain_manager = terrain_mgr
	_tile_size = Vector2i(int(tile_size.x), int(tile_size.y))
	
	# 如果没有TileSet，自动创建一个
	if not tile_set:
		tile_set = _create_tileset_resource()
	
	# 确保使用第 0 层
	set_layer_enabled(0, true)
	
	# 设置 z_index 确保地形在地下层
	z_index = 0

func render_terrain() -> void:
	clear()
	
	if not _terrain_manager or not _terrain_manager.is_initialized():
		return
	
	var width = _terrain_manager.GetWidth()
	var height = _terrain_manager.GetHeight()
	
	# 使用 TileMap 渲染
	for x in range(width):
		for y in range(height):
			var terrain_type = _terrain_manager.GetTerrainType(x, y)
			var tile_id = _get_tile_id(terrain_type)
			set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _get_tile_id(terrain_type: Enums.TerrainType) -> int:
	match terrain_type:
		Enums.TerrainType.UNDUG:
			return TILE_UNDUG
		Enums.TerrainType.DUG:
			return TILE_DUG
		Enums.TerrainType.WALL:
			return TILE_WALL
		_:
			return TILE_UNDUG

## 创建 TileSet 资源（运行时）
func _create_tileset_resource() -> TileSet:
	var tileset = TileSet.new()
	
	# 设置 TileSet 的 tile_size（关键！）
	tileset.tile_size = _tile_size
	
	# 添加图源
	var atlas = TileSetAtlasSource.new()
	atlas.texture_region_size = Vector2i(32, 32)
	
	# 创建3个纯色图片作为瓦片，合并到一个图集中
	var atlas_image = _create_atlas_image()
	var atlas_texture = ImageTexture.new()
	atlas_texture.set_image(atlas_image)
	
	atlas.texture = atlas_texture
	
	# 添加瓦片 0: UNDUG - RGB(30,30,30)
	atlas.create_tile(Vector2i(0, 0))
	
	# 添加瓦片 1: DUG - RGB(100,100,100)
	atlas.create_tile(Vector2i(1, 0))
	
	# 添加瓦片 2: WALL - RGB(60,60,60)
	atlas.create_tile(Vector2i(2, 0))
	
	tileset.add_source(atlas, 0)
	
	return tileset

## 创建图集图片
func _create_atlas_image() -> Image:
	# 创建96x32的图集（3个32x32瓦片横向排列）
	var image = Image.create(96, 32, false, Image.FORMAT_RGB8)
	
	# 瓦片0: UNDUG - RGB(30,30,30) = Color(0.118, 0.118, 0.118)
	var undug_color = Color(0.118, 0.118, 0.118)
	image.fill_rect(Rect2i(0, 0, 32, 32), undug_color)
	
	# 瓦片1: DUG - RGB(100,100,100) = Color(0.392, 0.392, 0.392)
	var dug_color = Color(0.392, 0.392, 0.392)
	image.fill_rect(Rect2i(32, 0, 32, 32), dug_color)
	
	# 瓦片2: WALL - RGB(60,60,60) = Color(0.235, 0.235, 0.235)
	var wall_color = Color(0.235, 0.235, 0.235)
	image.fill_rect(Rect2i(64, 0, 32, 32), wall_color)
	
	return image
