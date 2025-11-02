extends RefCounted
class_name CreateTileset

## 工具脚本：创建TileSet资源
## 这个脚本可以在运行时生成TileSet，用于测试
## 实际项目中应该在编辑器中手动创建TileSet资源

static func create_tileset_resource() -> TileSet:
	var tileset = TileSet.new()
	
	# 添加图源
	var atlas = TileSetAtlasSource.new()
	atlas.texture_region_size = Vector2i(32, 32)
	
	# 创建3个纯色图片作为瓦片，合并到一个图集中
	var atlas_image = create_atlas_image()
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

static func create_atlas_image() -> Image:
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
