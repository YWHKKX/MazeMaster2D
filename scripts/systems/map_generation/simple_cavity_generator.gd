extends RefCounted
class_name SimpleCavityGenerator

## 空洞生成器
## 支持生成矩形和基于噪声的随机形状空洞（参考 MazeMaster3D）

var _terrain_manager: TerrainManager
var _cavity_manager: CavityManager
var _shape_generator: HoleShapeGenerator

## 空洞形状枚举
enum CavityShape {
	RECTANGLE, # 矩形
	ELLIPSE, # 椭圆形
	NOISE, # 噪声形状（基础不规则形状）
	ORGANIC # 有机形状（更复杂的噪声形状）
}

## 初始化
func _init(terrain_mgr: TerrainManager, cavity_mgr: CavityManager):
	_terrain_manager = terrain_mgr
	_cavity_manager = cavity_mgr
	_shape_generator = HoleShapeGenerator.new()

## 生成空洞（支持随机形状）
## center: 中心位置
## base_size: 基础大小（用于计算范围）
## type: 空洞类型
## shape: 空洞形状（默认矩形，传入-1表示随机）
func GenerateCavity(
	center: Vector2i,
	base_size: Vector2i,
	type: Enums.CavityType,
	shape: int = CavityShape.RECTANGLE
) -> Cavity:
	# 如果shape为-1，随机选择形状（包括噪声形状）
	if shape == -1:
		shape = randi() % 4
	
	var cavity_shape = shape as CavityShape
	
	# 根据形状生成
	match cavity_shape:
		CavityShape.RECTANGLE:
			return GenerateRectangularCavity(center, base_size, type)
		CavityShape.ELLIPSE:
			return GenerateEllipticalCavity(center, base_size, type)
		CavityShape.NOISE:
			return GenerateNoiseCavity(center, base_size, type)
		CavityShape.ORGANIC:
			return GenerateOrganicCavity(center, base_size, type)
		_:
			return GenerateRectangularCavity(center, base_size, type)

## 生成矩形空洞
## 如果边界无效或与现有空洞重叠，返回 null
func GenerateRectangularCavity(
	center: Vector2i,
	size: Vector2i,
	type: Enums.CavityType
) -> Cavity:
	# 验证边界
	if not _validate_cavity_bounds(center, size):
		push_warning("Invalid cavity bounds at center %s with size %s" % [center, size])
		return null
	
	# 直接计算位置列表（避免创建临时对象浪费ID）
	var positions: Array[Vector2i] = []
	var start_x = center.x - (size.x / 2)
	var end_x = start_x + size.x
	var start_y = center.y - (size.y / 2)
	var end_y = start_y + size.y
	
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			positions.append(Vector2i(x, y))
	
	# 检查是否与现有空洞重叠
	if _check_cavity_overlap(positions):
		push_warning("Cavity overlaps with existing cavity at center %s" % center)
		return null
	
	# 创建实际空洞对象
	var id = _cavity_manager.GetNextId()
	var cavity = Cavity.new(id, type, center, size)
	
	# 挖掘地形
	for pos in cavity.positions:
		_terrain_manager.SetTerrainType(pos.x, pos.y, Enums.TerrainType.DUG)
	
	# 注册空洞
	_cavity_manager.RegisterCavity(cavity)
	
	return cavity

## 生成椭圆形空洞
func GenerateEllipticalCavity(
	center: Vector2i,
	base_size: Vector2i,
	type: Enums.CavityType
) -> Cavity:
	# 使用基础大小的随机变化作为椭圆半径
	var radius_x = base_size.x / 2.0 + randf_range(-1, 1)
	var radius_y = base_size.y / 2.0 + randf_range(-1, 1)
	radius_x = max(2.0, radius_x)
	radius_y = max(2.0, radius_y)
	
	# 计算边界框
	var min_x = int(center.x - radius_x)
	var max_x = int(center.x + radius_x)
	var min_y = int(center.y - radius_y)
	var max_y = int(center.y + radius_y)
	
	# 验证边界
	if not _validate_area(min_x, max_x, min_y, max_y):
		return null
	
	# 生成椭圆内的点
	var positions: Array[Vector2i] = []
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var dx = (x - center.x) / radius_x
			var dy = (y - center.y) / radius_y
			# 椭圆方程: (dx)^2 + (dy)^2 <= 1
			if dx * dx + dy * dy <= 1.0:
				var pos = Vector2i(x, y)
				if _terrain_manager.IsValidPosition(pos.x, pos.y):
					positions.append(pos)
	
	if positions.is_empty():
		return null
	
	# 检查是否与现有空洞重叠
	if _check_cavity_overlap(positions):
		push_warning("Elliptical cavity overlaps with existing cavity at center %s" % center)
		return null
	
	# 创建空洞对象（使用实际边界作为size）
	var actual_size = Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	var id = _cavity_manager.GetNextId()
	var cavity = Cavity.new(id, type, center, actual_size)
	cavity.positions = positions
	
	# 挖掘地形
	for pos in positions:
		_terrain_manager.SetTerrainType(pos.x, pos.y, Enums.TerrainType.DUG)
	
	# 注册空洞
	_cavity_manager.RegisterCavity(cavity)
	
	return cavity

## 生成噪声形状空洞（基于 FastNoiseLite）
func GenerateNoiseCavity(
	center: Vector2i,
	base_size: Vector2i,
	type: Enums.CavityType
) -> Cavity:
	var radius_base = max(base_size.x, base_size.y) / 2.0
	
	# 配置形状生成器
	_shape_generator.set_shape_parameters(radius_base, 24, 0.8)
	_shape_generator.set_noise_parameters(0.1, randi())
	
	# 使用噪声形状生成器生成位置
	var center_float = Vector2(center.x, center.y)
	var positions = _shape_generator.generate_cavity_positions(
		center_float,
		"noise",
		_terrain_manager.GetWidth(),
		_terrain_manager.GetHeight()
	)
	
	if positions.is_empty():
		return null
	
	# 检查是否与现有空洞重叠
	if _check_cavity_overlap(positions):
		push_warning("Noise cavity overlaps with existing cavity at center %s" % center)
		return null
	
	# 计算实际边界
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_y = positions[0].y
	var max_y = positions[0].y
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# 创建空洞对象
	var actual_size = Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	var id = _cavity_manager.GetNextId()
	var cavity = Cavity.new(id, type, center, actual_size)
	cavity.positions = positions
	
	# 挖掘地形
	for pos in positions:
		_terrain_manager.SetTerrainType(pos.x, pos.y, Enums.TerrainType.DUG)
	
	# 注册空洞
	_cavity_manager.RegisterCavity(cavity)
	
	return cavity

## 生成有机形状空洞（更复杂的噪声形状）
func GenerateOrganicCavity(
	center: Vector2i,
	base_size: Vector2i,
	type: Enums.CavityType
) -> Cavity:
	var radius_base = max(base_size.x, base_size.y) / 2.0
	
	# 配置形状生成器
	_shape_generator.set_shape_parameters(radius_base, 24, 0.8)
	_shape_generator.set_noise_parameters(0.1, randi())
	
	# 使用有机形状生成器生成位置
	var center_float = Vector2(center.x, center.y)
	var positions = _shape_generator.generate_cavity_positions(
		center_float,
		"organic",
		_terrain_manager.GetWidth(),
		_terrain_manager.GetHeight()
	)
	
	if positions.is_empty():
		return null
	
	# 检查是否与现有空洞重叠
	if _check_cavity_overlap(positions):
		push_warning("Organic cavity overlaps with existing cavity at center %s" % center)
		return null
	
	# 计算实际边界
	var min_x = positions[0].x
	var max_x = positions[0].x
	var min_y = positions[0].y
	var max_y = positions[0].y
	for pos in positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# 创建空洞对象
	var actual_size = Vector2i(max_x - min_x + 1, max_y - min_y + 1)
	var id = _cavity_manager.GetNextId()
	var cavity = Cavity.new(id, type, center, actual_size)
	cavity.positions = positions
	
	# 挖掘地形
	for pos in positions:
		_terrain_manager.SetTerrainType(pos.x, pos.y, Enums.TerrainType.DUG)
	
	# 注册空洞
	_cavity_manager.RegisterCavity(cavity)
	
	return cavity

## 验证空洞边界
func _validate_cavity_bounds(center: Vector2i, size: Vector2i) -> bool:
	# 与_update_positions保持一致
	var start_x = center.x - (size.x / 2)
	var start_y = center.y - (size.y / 2)
	# 最大有效格子坐标是 start + size - 1
	var max_x = start_x + size.x - 1
	var max_y = start_y + size.y - 1
	
	return _validate_area(start_x, max_x, start_y, max_y)

## 验证区域边界
func _validate_area(min_x: int, max_x: int, min_y: int, max_y: int) -> bool:
	# 检查是否在地图范围内
	if min_x < 0 or max_x >= _terrain_manager.GetWidth():
		return false
	if min_y < 0 or max_y >= _terrain_manager.GetHeight():
		return false
	return true

## 检查空洞位置是否与现有空洞重叠
## new_positions: 新空洞的位置列表
## 返回：true 如果有重叠，false 如果没有重叠
func _check_cavity_overlap(new_positions: Array[Vector2i]) -> bool:
	if new_positions.is_empty():
		return false
	
	# 获取所有已存在的空洞
	var existing_cavities = _cavity_manager.GetAllCavities()
	
	# 将新空洞的位置转换为集合（使用字典的键来实现快速查找）
	var new_positions_set = {}
	for pos in new_positions:
		var key = "%d,%d" % [pos.x, pos.y]
		new_positions_set[key] = true
	
	# 检查每个现有空洞的位置
	for existing_cavity in existing_cavities:
		for existing_pos in existing_cavity.positions:
			var key = "%d,%d" % [existing_pos.x, existing_pos.y]
			if new_positions_set.has(key):
				return true  # 发现重叠
	
	return false  # 没有重叠
