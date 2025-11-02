extends Node2D
class_name PathVisualizer

## 路径可视化器
## 可视化显示寻路路径、起点和终点

var _current_path: Array[Vector2i] = []
var _start_point: Vector2i = Vector2i(-1, -1)
var _end_point: Vector2i = Vector2i(-1, -1)
var _tile_size: Vector2 = Vector2(32, 32)
var _path_line: Line2D
var _start_marker: ColorRect
var _end_marker: ColorRect

## 初始化
func setup(tile_size: Vector2 = Vector2(32, 32)) -> void:
	_tile_size = tile_size
	_clear_markers()

## 设置路径
## @param path: 路径数组（Vector2i数组）
func set_path(path: Array[Vector2i]) -> void:
	_current_path = path
	_update_visualization()

## 设置起点
func set_start_point(point: Vector2i) -> void:
	_start_point = point
	_update_markers()

## 设置终点
func set_end_point(point: Vector2i) -> void:
	_end_point = point
	_update_markers()

## 清除路径
func clear_path() -> void:
	_current_path.clear()
	_start_point = Vector2i(-1, -1)
	_end_point = Vector2i(-1, -1)
	_clear_visualization()

## 更新可视化
func _update_visualization() -> void:
	_clear_visualization()
	
	if _current_path.is_empty():
		return
	
	# 创建路径线
	_path_line = Line2D.new()
	_path_line.width = 3.0
	_path_line.default_color = Color.YELLOW
	
	# 添加路径点
	for pos in _current_path:
		var world_pos = _grid_to_world(pos)
		_path_line.add_point(world_pos)
	
	add_child(_path_line)
	
	# 更新标记
	_update_markers()

## 更新起点和终点标记
func _update_markers() -> void:
	_clear_markers()
	
	# 创建起点标记（绿色）
	if _start_point.x >= 0 and _start_point.y >= 0:
		_start_marker = _create_marker(_start_point, Color.GREEN)
		if _start_marker:
			add_child(_start_marker)
	
	# 创建终点标记（红色）
	if _end_point.x >= 0 and _end_point.y >= 0:
		_end_marker = _create_marker(_end_point, Color.RED)
		if _end_marker:
			add_child(_end_marker)

## 创建标记
func _create_marker(grid_pos: Vector2i, color: Color) -> ColorRect:
	var marker = ColorRect.new()
	marker.size = _tile_size * 0.6  # 稍微小一点，不遮挡整个瓦块
	marker.position = _grid_to_world(grid_pos) - marker.size / 2.0
	marker.color = color
	marker.modulate.a = 0.8  # 半透明
	return marker

## 网格坐标转世界坐标
func _grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * _tile_size.x + _tile_size.x / 2.0,
		grid_pos.y * _tile_size.y + _tile_size.y / 2.0
	)

## 清除可视化
func _clear_visualization() -> void:
	if is_instance_valid(_path_line):
		_path_line.queue_free()
	_path_line = null

## 清除标记
func _clear_markers() -> void:
	if is_instance_valid(_start_marker):
		_start_marker.queue_free()
	if is_instance_valid(_end_marker):
		_end_marker.queue_free()
	_start_marker = null
	_end_marker = null

