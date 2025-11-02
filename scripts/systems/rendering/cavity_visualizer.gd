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

## 绘制空洞边界
func _draw_cavity_boundary(cavity: Cavity) -> void:
	if cavity.positions.is_empty():
		return
	
	var bounds = cavity.get_bounds()
	var color = _get_cavity_color(cavity.type)
	
	# 创建边界框
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = color
	
	# 绘制矩形边界
	var top_left = Vector2(bounds.position.x * _tile_size.x, bounds.position.y * _tile_size.y)
	var top_right = Vector2((bounds.position.x + bounds.size.x) * _tile_size.x, bounds.position.y * _tile_size.y)
	var bottom_right = Vector2((bounds.position.x + bounds.size.x) * _tile_size.x, (bounds.position.y + bounds.size.y) * _tile_size.y)
	var bottom_left = Vector2(bounds.position.x * _tile_size.x, (bounds.position.y + bounds.size.y) * _tile_size.y)
	
	line.add_point(top_left)
	line.add_point(top_right)
	line.add_point(bottom_right)
	line.add_point(bottom_left)
	line.add_point(top_left)  # 闭合
	
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

## 清除所有可视化
func _clear_cavities() -> void:
	for line in _cavity_lines:
		if is_instance_valid(line):
			line.queue_free()
	for line in _channel_lines:
		if is_instance_valid(line):
			line.queue_free()
	_cavity_lines.clear()
	_channel_lines.clear()

