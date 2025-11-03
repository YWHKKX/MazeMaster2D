extends Node2D
class_name CavityVisualizer

## 空洞可视化器
## 使用 Line2D 或 Polygon2D 显示空洞边界

var _cavity_manager: CavityManager
var _tile_size: Vector2 = Vector2(32, 32)
var _cavity_lines: Array[Line2D] = []
var _channel_lines: Array[Line2D] = []

## 初始化
func setup(cavity_mgr: CavityManager, tile_size: Vector2 = Vector2(32, 32)) -> void:
	_cavity_manager = cavity_mgr
	_tile_size = tile_size

## 渲染空洞
func render_cavities() -> void:
	_clear_cavities()
	
	if not _cavity_manager or not _cavity_manager.is_initialized():
		return
	
	var cavities = _cavity_manager.GetAllCavities()
	for cavity in cavities:
		_draw_cavity_boundary(cavity)

## 绘制单个空洞边界（立即生成）
## 在空洞生成后立即调用此方法
func draw_cavity_immediately(cavity: Cavity) -> void:
	_draw_cavity_boundary(cavity)

## 绘制空洞边界
func _draw_cavity_boundary(cavity: Cavity) -> void:
	if cavity.positions.is_empty():
		return
	
	var color = _get_cavity_color(cavity.type)
	var line_width = _get_cavity_line_width(cavity.size_category)
	
	# 创建边界框
	var line = Line2D.new()
	line.width = line_width
	line.default_color = color
	
	# 直接从positions计算实际边界，避免get_bounds的size问题
	var min_x = cavity.positions[0].x
	var max_x = cavity.positions[0].x
	var min_y = cavity.positions[0].y
	var max_y = cavity.positions[0].y
	
	for pos in cavity.positions:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# 绘制矩形边界
	# TileMap 中格子 (x, y) 占据像素范围 [x*tile_size, (x+1)*tile_size)
	# 所以边界框的四个角应该使用格子边界
	var top_left = Vector2(min_x * _tile_size.x, min_y * _tile_size.y)
	var top_right = Vector2((max_x + 1) * _tile_size.x, min_y * _tile_size.y)
	var bottom_right = Vector2((max_x + 1) * _tile_size.x, (max_y + 1) * _tile_size.y)
	var bottom_left = Vector2(min_x * _tile_size.x, (max_y + 1) * _tile_size.y)
	
	line.add_point(top_left)
	line.add_point(top_right)
	line.add_point(bottom_right)
	line.add_point(bottom_left)
	line.add_point(top_left) # 闭合
	
	add_child(line)
	_cavity_lines.append(line)

## 获取空洞颜色
func _get_cavity_color(cavity_type: Enums.CavityType) -> Color:
	match cavity_type:
		Enums.CavityType.CRITICAL:
			return Color.RED
		Enums.CavityType.FUNCTIONAL:
			return Color.BLUE
		Enums.CavityType.ECOSYSTEM:
			return Color.GREEN
		_:
			return Color.WHITE

## 获取空洞边框宽度
func _get_cavity_line_width(size_category: Enums.CavitySize) -> float:
	match size_category:
		Enums.CavitySize.SMALL:
			return 1.0
		Enums.CavitySize.MEDIUM:
			return 2.0
		Enums.CavitySize.LARGE:
			return 3.0
		_:
			return 2.0

## 清除所有可视化（内部方法）
func _clear_cavities() -> void:
	for line in _cavity_lines:
		if is_instance_valid(line):
			line.queue_free()
	for line in _channel_lines:
		if is_instance_valid(line):
			line.queue_free()
	_cavity_lines.clear()
	_channel_lines.clear()

## 清除所有可视化（公开方法）
func clear_cavities() -> void:
	_clear_cavities()
