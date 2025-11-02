extends RefCounted
class_name HoleShapeGenerator

## 噪声形状空洞生成器
## 基于噪声为每个中心点生成不规则空洞形状（参考 MazeMaster3D）

var noise: FastNoiseLite
var hole_radius: float = 10.0
var noise_threshold: float = 0.3
var noise_scale: float = 0.1
var shape_detail: int = 24 # 形状细节点数，让边界更平滑
var irregularity_factor: float = 0.8 # 不规则程度

## 初始化
func _init():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.1
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

## 生成噪声形状轮廓点
## @param center: 空洞中心点
## @param map_width: 地图宽度
## @param map_height: 地图高度
## @return: 形状轮廓点数组
func generate_hole_shape(center: Vector2, map_width: int, map_height: int) -> PackedVector2Array:
	var shape_points = PackedVector2Array()
	
	# 在圆周上采样并应用噪声扰动
	for i in range(shape_detail):
		var angle = TAU * i / shape_detail
		var base_dir = Vector2(cos(angle), sin(angle))
		
		# 使用多层噪声扰动半径，增强不规则性
		var noise_value = 0.0
		# 添加多个频率的噪声
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 3, center.y + base_dir.y * 3) * 0.5
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 8, center.y + base_dir.y * 8) * 0.3
		noise_value += noise.get_noise_2d(center.x + base_dir.x * 15, center.y + base_dir.y * 15) * 0.2
		
		# 增加不规则因子
		var enhanced_irregularity = irregularity_factor * 1.5
		var perturbed_radius = hole_radius * (1.0 + noise_value * enhanced_irregularity)
		
		# 添加随机扰动
		var random_factor = randf_range(-0.15, 0.15)
		perturbed_radius += hole_radius * random_factor
		var point = center + base_dir * perturbed_radius
		
		# 确保点在地图范围内
		point.x = clamp(point.x, 0, map_width - 1)
		point.y = clamp(point.y, 0, map_height - 1)
		shape_points.append(point)
	
	return shape_points

## 生成有机形状（更复杂的噪声形状）
## @param center: 空洞中心点
## @param map_width: 地图宽度
## @param map_height: 地图高度
## @return: 形状轮廓点数组
func generate_organic_shape(center: Vector2, map_width: int, map_height: int) -> PackedVector2Array:
	var shape_points = PackedVector2Array()
	var num_layers = 5 # 增加噪声层数，让形状更复杂
	
	for i in range(shape_detail):
		var angle = TAU * i / shape_detail
		var base_dir = Vector2(cos(angle), sin(angle))
		var total_radius = hole_radius
		
		# 多层噪声叠加，增强不规则性
		for layer in range(num_layers):
			var layer_scale = pow(1.5, layer) # 调整缩放因子，让变化更平滑
			var layer_noise = noise.get_noise_2d(
				center.x + base_dir.x * layer_scale * 2,
				center.y + base_dir.y * layer_scale * 2
			)
			# 增加噪声影响，让形状更不规则
			var noise_strength = hole_radius * (0.3 + 0.1 * layer) / layer_scale
			total_radius += layer_noise * noise_strength
		
		# 添加额外的随机扰动
		var random_perturbation = randf_range(-0.1, 0.1) * hole_radius
		total_radius += random_perturbation
		
		var point = center + base_dir * total_radius
		
		# 确保点在地图范围内
		point.x = clamp(point.x, 0, map_width - 1)
		point.y = clamp(point.y, 0, map_height - 1)
		shape_points.append(point)
	
	return shape_points

## 根据形状类型生成空洞位置
## @param center: 空洞中心点
## @param shape_type: 形状类型 ("noise", "organic")
## @param map_width: 地图宽度
## @param map_height: 地图高度
## @return: 挖掘位置数组（Vector2i）
func generate_cavity_positions(center: Vector2, shape_type: String, map_width: int, map_height: int) -> Array[Vector2i]:
	var shape_points = PackedVector2Array()
	
	match shape_type:
		"noise":
			shape_points = generate_hole_shape(center, map_width, map_height)
		"organic":
			shape_points = generate_organic_shape(center, map_width, map_height)
		_:
			# 默认使用噪声形状
			shape_points = generate_hole_shape(center, map_width, map_height)
	
	return _fill_polygon(shape_points, map_width, map_height)

## 填充多边形内的所有网格位置
## @param shape_points: 形状轮廓点数组
## @param map_width: 地图宽度
## @param map_height: 地图高度
## @return: 多边形内的网格位置数组
func _fill_polygon(shape_points: PackedVector2Array, map_width: int, map_height: int) -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	var bounding_rect = _calculate_bounding_rect(shape_points)
	
	# 在包围盒内检查每个网格点是否在多边形内
	var min_x = max(0, int(bounding_rect.position.x))
	var max_x = min(map_width - 1, int(bounding_rect.end.x))
	var min_y = max(0, int(bounding_rect.position.y))
	var max_y = min(map_height - 1, int(bounding_rect.end.y))
	
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var point = Vector2(x, y)
			if _is_point_in_polygon(point, shape_points):
				positions.append(Vector2i(x, y))
	
	return positions

## 计算形状的边界矩形
func _calculate_bounding_rect(points: PackedVector2Array) -> Rect2:
	if points.is_empty():
		return Rect2()
	
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	
	for point in points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

## 使用射线法判断点是否在多边形内
func _is_point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	var inside = false
	var j = polygon.size() - 1
	
	for i in range(polygon.size()):
		var xi = polygon[i].x
		var yi = polygon[i].y
		var xj = polygon[j].x
		var yj = polygon[j].y
		
		var intersect = ((yi > point.y) != (yj > point.y)) and \
		                (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi)
		if intersect:
			inside = not inside
		j = i
	
	return inside

## 设置形状参数
func set_shape_parameters(radius: float, detail: int = 24, irregularity: float = 0.8) -> void:
	hole_radius = radius
	shape_detail = detail
	irregularity_factor = irregularity

## 设置噪声参数
func set_noise_parameters(frequency: float, seed_value: int) -> void:
	noise.frequency = frequency
	noise.seed = seed_value
