extends RefCounted
class_name Cavity

## 空洞数据结构
## 表示地图上的一个空洞区域

var id: int
var type: Enums.CavityType
var size_category: Enums.CavitySize # 大小分类（小/中/大）
var center: Vector2i # 中心位置（网格坐标）
var size: Vector2i # 大小（宽度、高度）
var positions: Array[Vector2i] = [] # 所有位置列表

## 构造函数
func _init(p_id: int, p_type: Enums.CavityType, p_center: Vector2i, p_size: Vector2i):
	id = p_id
	type = p_type
	center = p_center
	size = p_size
	size_category = _determine_size_category(p_size)
	_update_positions()

## 根据大小判断大小分类
func _determine_size_category(actual_size: Vector2i) -> Enums.CavitySize:
	var area = actual_size.x * actual_size.y
	# 更新的大小分类标准（与 map_generator.gd 保持一致）
	# 小空洞：面积 <= 30 (4x4=16, 5x5=25等)
	# 中空洞：30 < 面积 <= 100 (8x8=64, 9x9=81等)
	# 大空洞：面积 > 100 (12x12=144等)
	if area <= 30:
		return Enums.CavitySize.SMALL
	elif area <= 100:
		return Enums.CavitySize.MEDIUM
	else:
		return Enums.CavitySize.LARGE

## 更新位置列表
func _update_positions() -> void:
	positions.clear()
	# 生成size个格子，中心为center
	# 对于奇数size，包含center本身；对于偶数size，中心在格子之间
	var start_x = center.x - (size.x / 2)
	var end_x = start_x + size.x
	var start_y = center.y - (size.y / 2)
	var end_y = start_y + size.y
	
	for x in range(start_x, end_x):
		for y in range(start_y, end_y):
			positions.append(Vector2i(x, y))

## 检查位置是否在空洞内
func contains(pos: Vector2i) -> bool:
	return positions.has(pos)

## 获取边界框
func get_bounds() -> Rect2i:
	if positions.is_empty():
		return Rect2i()
	
	var min_pos = positions[0]
	var max_pos = positions[0]
	
	for pos in positions:
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)
	
	return Rect2i(min_pos, max_pos - min_pos + Vector2i(1, 1))

## 获取空洞面积
func get_area() -> int:
	return positions.size()
