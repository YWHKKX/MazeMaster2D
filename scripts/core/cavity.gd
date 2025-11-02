extends RefCounted
class_name Cavity

## 空洞数据结构
## 表示地图上的一个空洞区域

var id: int
var type: Enums.CavityType
var center: Vector2i  # 中心位置（网格坐标）
var size: Vector2i    # 大小（宽度、高度）
var positions: Array[Vector2i] = []  # 所有位置列表

## 构造函数
func _init(p_id: int, p_type: Enums.CavityType, p_center: Vector2i, p_size: Vector2i):
	id = p_id
	type = p_type
	center = p_center
	size = p_size
	_update_positions()

## 更新位置列表
func _update_positions() -> void:
	positions.clear()
	var half_width = size.x / 2.0
	var half_height = size.y / 2.0
	
	var min_x = int(center.x - half_width)
	var max_x = int(center.x + half_width)
	var min_y = int(center.y - half_height)
	var max_y = int(center.y + half_height)
	
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
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

