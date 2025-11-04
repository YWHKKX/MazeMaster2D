extends RefCounted
class_name PixelArtGenerator

## 像素艺术生成器
## 用于动态生成资源瓦块的像素艺术纹理

## 创建资源瓦块图像
## resource_type: 资源类型
## tile_size: 瓦块大小（默认32x32）
## 返回：生成的Image对象
func create_resource_tile_image(resource_type: Enums.ResourceType, tile_size: Vector2i = Vector2i(32, 32)) -> Image:
	var image = Image.create(tile_size.x, tile_size.y, false, Image.FORMAT_RGBA8)
	
	match resource_type:
		Enums.ResourceType.GOLD:
			_draw_gold_mine(image, tile_size)
		Enums.ResourceType.MANA:
			_draw_mana_crystal(image, tile_size)
		Enums.ResourceType.FOOD:
			_draw_food_nest(image, tile_size)
		Enums.ResourceType.IRON:
			_draw_iron_ore(image, tile_size)
		_:
			# 默认：白色矩形
			image.fill(Color.WHITE)
	
	return image

## 绘制金矿图案
func _draw_gold_mine(image: Image, size: Vector2i) -> void:
	var gold_base = Color(1.0, 0.84, 0.0)  # 金色
	var gold_dark = Color(0.8, 0.6, 0.0)   # 深金色
	var gold_light = Color(1.0, 0.95, 0.5) # 浅金色（高光）
	var gold_border = Color(0.7, 0.55, 0.0) # 边框色
	
	# 填充背景
	image.fill(gold_base)
	
	# 绘制方块堆叠（3-4层）
	# 底层（最大）
	var bottom_y = size.y - 6
	var bottom_width = size.x - 4
	var bottom_x = 2
	_fill_rect(image, bottom_x, bottom_y, bottom_width, 4, gold_dark)
	
	# 中层
	var middle_y = bottom_y - 5
	var middle_width = bottom_width - 4
	var middle_x = bottom_x + 2
	_fill_rect(image, middle_x, middle_y, middle_width, 3, gold_base)
	
	# 顶层（最小）
	var top_y = middle_y - 4
	var top_width = middle_width - 3
	var top_x = middle_x + 1
	_fill_rect(image, top_x, top_y, top_width, 2, gold_light)
	
	# 绘制高光（顶部2-3像素）
	var highlight_y = top_y - 1
	if highlight_y >= 0:
		_fill_rect(image, top_x + 1, highlight_y, top_width - 2, 1, gold_light)
	
	# 绘制边框
	_draw_rect_border(image, 0, 0, size.x, size.y, gold_border)

## 绘制魔力水晶图案
func _draw_mana_crystal(image: Image, size: Vector2i) -> void:
	var purple_base = Color(0.5, 0.2, 1.0)   # 紫色
	var purple_dark = Color(0.3, 0.1, 0.7)  # 深紫色
	var purple_light = Color(0.7, 0.4, 1.0)  # 浅紫色
	var purple_border = Color(0.2, 0.05, 0.5) # 边框色
	
	# 填充背景
	image.fill(purple_base)
	
	# 绘制菱形水晶形状（中心）
	var center_x = size.x / 2
	var center_y = size.y / 2
	var diamond_size = 10
	
	# 绘制菱形（使用填充三角形的方式）
	for y in range(size.y):
		for x in range(size.x):
			var dx = abs(x - center_x)
			var dy = abs(y - center_y)
			if dx + dy <= diamond_size:
				var dist = float(dx + dy) / float(diamond_size)
				var color = purple_base.lerp(purple_light, 1.0 - dist * 0.5)
				image.set_pixel(x, y, color)
	
	# 绘制内部高光（渐变）
	var highlight_size = diamond_size - 2
	for y in range(size.y):
		for x in range(size.x):
			var dx = abs(x - center_x)
			var dy = abs(y - center_y)
			if dx + dy <= highlight_size:
				var dist = float(dx + dy) / float(highlight_size)
				var color = purple_light.lerp(purple_base, dist * 0.3)
				image.set_pixel(x, y, color)
	
	# 绘制边框
	_draw_rect_border(image, 0, 0, size.x, size.y, purple_border)

## 绘制食物/肉虫穴图案
func _draw_food_nest(image: Image, size: Vector2i) -> void:
	var brown_base = Color(0.8, 0.6, 0.4)   # 棕色
	var brown_dark = Color(0.6, 0.4, 0.2)  # 深棕色
	var brown_light = Color(0.9, 0.7, 0.5) # 浅棕色
	var brown_border = Color(0.5, 0.3, 0.1) # 边框色
	
	# 填充背景
	image.fill(brown_base)
	
	# 绘制有机虫穴形状（不规则圆形）
	var center_x = size.x / 2
	var center_y = size.y / 2
	var radius = 10
	
	# 绘制虫穴主体（椭圆）
	for y in range(size.y):
		for x in range(size.x):
			var dx = float(x - center_x) / float(radius)
			var dy = float(y - center_y) / float(radius * 0.8)
			var dist_sq = dx * dx + dy * dy
			if dist_sq <= 1.0:
				# 内部点状纹理
				var noise = (x + y * 3) % 3
				var color = brown_base if noise == 0 else brown_dark
				image.set_pixel(x, y, color)
	
	# 绘制内部纹理（点状）
	for y in range(center_y - 5, center_y + 5):
		for x in range(center_x - 5, center_x + 5):
			if (x + y) % 2 == 0 and (x - center_x) * (x - center_x) + (y - center_y) * (y - center_y) < 25:
				image.set_pixel(x, y, brown_light)
	
	# 绘制边框
	_draw_rect_border(image, 0, 0, size.x, size.y, brown_border)

## 绘制铁矿图案
func _draw_iron_ore(image: Image, size: Vector2i) -> void:
	var gray_base = Color(0.4, 0.4, 0.45)   # 深灰色
	var gray_dark = Color(0.2, 0.2, 0.2)    # 黑色
	var gray_light = Color(0.6, 0.6, 0.65)  # 浅灰色（金属反光）
	var gray_border = Color(0.1, 0.1, 0.1)   # 边框色
	
	# 填充背景
	image.fill(gray_base)
	
	# 绘制矿石块形状（不规则矩形）
	var ore_x = 4
	var ore_y = 6
	var ore_width = size.x - 8
	var ore_height = size.y - 12
	
	# 绘制矿石主体
	_fill_rect(image, ore_x, ore_y, ore_width, ore_height, gray_dark)
	
	# 绘制金属反光（左上角高光）
	var highlight_x = ore_x + 2
	var highlight_y = ore_y + 2
	var highlight_width = ore_width / 3
	var highlight_height = ore_height / 3
	_fill_rect(image, highlight_x, highlight_y, highlight_width, highlight_height, gray_light)
	
	# 绘制纹理线条
	for i in range(3):
		var line_y = ore_y + ore_height / 4 * (i + 1)
		_draw_horizontal_line(image, ore_x + 1, line_y, ore_width - 2, gray_base)
	
	# 绘制边框
	_draw_rect_border(image, 0, 0, size.x, size.y, gray_border)

## 辅助方法：填充矩形区域
func _fill_rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	for py in range(y, min(y + height, image.get_height())):
		for px in range(x, min(x + width, image.get_width())):
			if px >= 0 and py >= 0:
				image.set_pixel(px, py, color)

## 辅助方法：绘制矩形边框
func _draw_rect_border(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	# 上边框
	for px in range(x, min(x + width, image.get_width())):
		if px >= 0 and y >= 0:
			image.set_pixel(px, y, color)
	
	# 下边框
	var bottom_y = y + height - 1
	for px in range(x, min(x + width, image.get_width())):
		if px >= 0 and bottom_y < image.get_height():
			image.set_pixel(px, bottom_y, color)
	
	# 左边框
	for py in range(y, min(y + height, image.get_height())):
		if x >= 0 and py >= 0:
			image.set_pixel(x, py, color)
	
	# 右边框
	var right_x = x + width - 1
	for py in range(y, min(y + height, image.get_height())):
		if right_x < image.get_width() and py >= 0:
			image.set_pixel(right_x, py, color)

## 辅助方法：绘制水平线
func _draw_horizontal_line(image: Image, x: int, y: int, length: int, color: Color) -> void:
	for px in range(x, min(x + length, image.get_width())):
		if px >= 0 and y >= 0 and y < image.get_height():
			image.set_pixel(px, y, color)

