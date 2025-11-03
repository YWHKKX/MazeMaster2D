extends Node2D
class_name EntityRenderer

## 实体渲染器
## 使用子节点渲染所有实体（建筑瓦块、资源瓦块、单位）

var _tile_manager: TileManager = null
var _unit_manager: UnitManager = null
var _tile_size: Vector2i = Vector2i(32, 32)

# 用于跟踪已渲染的建筑（避免重复渲染多格建筑）
var _rendered_buildings: Dictionary = {}

## 初始化
func setup(tile_mgr: TileManager, unit_mgr: UnitManager, tile_size: Vector2i = Vector2i(32, 32)) -> void:
	_tile_manager = tile_mgr
	_unit_manager = unit_mgr
	_tile_size = tile_size
	
	# 设置 z_index 确保 EntityRenderer 及其子节点渲染在地形之上
	z_index = 10

## 渲染所有实体
func render_entities() -> void:
	clear()
	_rendered_buildings.clear()
	
	if not _tile_manager:
		return
	
	# 渲染建筑瓦块（从Tile读取）
	_render_building_tiles()
	
	# 渲染资源瓦块（从Tile读取）
	_render_resource_tiles()
	
	# 渲染单位（独立的单位实体）
	if _unit_manager and _unit_manager.is_initialized():
		_render_units()

## 清空所有渲染
func clear() -> void:
	for child in get_children():
		child.queue_free()

## 渲染建筑瓦块（从Tile读取）
func _render_building_tiles() -> void:
	if not _tile_manager:
		return
	
	var width = _tile_manager.GetWidth()
	var height = _tile_manager.GetHeight()
	
	# 遍历所有瓦块，查找建筑
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var building_data = _tile_manager.GetBuildingTile(pos)
			if building_data:
				# 检查是否已经渲染过这个建筑（多格建筑）
				var building_key = "%d,%d" % [pos.x, pos.y]
				if not _rendered_buildings.has(building_key):
					# 找到建筑左上角（建筑可能跨越多个格子）
					var building_start = _find_building_start(pos, building_data)
					if building_start:
						_create_building_visual(building_start, building_data)
						# 标记这个建筑的所有格子都已渲染
						for bx in range(building_data.size.x):
							for by in range(building_data.size.y):
								var bpos = building_start + Vector2i(bx, by)
								var key = "%d,%d" % [bpos.x, bpos.y]
								_rendered_buildings[key] = true

## 查找建筑的左上角位置
func _find_building_start(pos: Vector2i, building_data: BuildingTile) -> Vector2i:
	# 简单的实现：从当前位置向左上搜索，找到建筑的最小边界
	# 这里假设建筑是连续放置的，从左上角开始
	return pos  # 简化实现，假设pos就是左上角

## 创建建筑可视化节点
func _create_building_visual(tile_pos: Vector2i, building_data: BuildingTile) -> void:
	var world_pos = Vector2(tile_pos.x * _tile_size.x, tile_pos.y * _tile_size.y)
	var world_size = Vector2(building_data.size.x * _tile_size.x, building_data.size.y * _tile_size.y)
	
	# 根据建筑类型选择颜色
	var color = _get_building_color(building_data)
	
	# 创建ColorRect节点用于填充
	var fill_rect = ColorRect.new()
	fill_rect.position = world_pos
	fill_rect.size = world_size
	fill_rect.color = color
	fill_rect.color.a = 0.3  # 半透明填充
	fill_rect.z_index = 10  # 确保建筑显示在地形之上
	add_child(fill_rect)
	
	# 创建Line2D节点用于边框
	var border_line = Line2D.new()
	border_line.width = 3.0
	border_line.default_color = color
	border_line.z_index = 11  # 边框在建筑填充之上
	
	var points = [
		world_pos,
		Vector2(world_pos.x + world_size.x, world_pos.y),
		Vector2(world_pos.x + world_size.x, world_pos.y + world_size.y),
		Vector2(world_pos.x, world_pos.y + world_size.y),
		world_pos  # 闭合
	]
	
	for point in points:
		border_line.add_point(point)
	
	add_child(border_line)

## 获取建筑颜色
func _get_building_color(building_data: BuildingTile) -> Color:
	if building_data is DungeonHeartTile:
		return Color(0.8, 0.2, 0.2)  # 深红色 = 地牢之心
	else:
		return Color(0.6, 0.4, 0.2)  # 棕色 = 其他建筑

## 渲染资源瓦块（从Tile读取）
func _render_resource_tiles() -> void:
	if not _tile_manager:
		return
	
	var width = _tile_manager.GetWidth()
	var height = _tile_manager.GetHeight()
	
	# 遍历所有瓦块，查找资源
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var resource_data = _tile_manager.GetResourceTile(pos)
			if resource_data:
				_create_resource_tile_visual(pos, resource_data)

## 创建资源瓦块可视化节点
func _create_resource_tile_visual(tile_pos: Vector2i, resource_data: ResourceTile) -> void:
	var world_pos = Vector2(tile_pos.x * _tile_size.x, tile_pos.y * _tile_size.y)
	var radius = float(_tile_size.x) * 0.3  # 圆形半径为瓦块大小的30%
	
	# 根据资源类型选择颜色
	var color = _get_resource_node_color(resource_data.resource_type)
	
	# 创建圆形Sprite节点（使用简单的圆形纹理或ColorRect）
	# 由于Godot没有直接的圆形节点，我们使用ColorRect配合自定义shader或使用Polygon2D
	# 这里使用Polygon2D创建圆形
	
	var polygon = Polygon2D.new()
	polygon.color = color
	polygon.position = world_pos
	polygon.z_index = 10  # 确保资源显示在地形之上
	
	# 生成圆形顶点（16边形近似圆形）
	var points: PackedVector2Array = []
	var segments = 16
	for i in range(segments + 1):
		var angle = (float(i) / float(segments)) * TAU
		var point = Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
	
	polygon.polygon = points
	add_child(polygon)
	
	# 创建边框（使用Line2D）
	var border_line = Line2D.new()
	border_line.width = 2.0
	border_line.default_color = Color.BLACK
	border_line.z_index = 11  # 边框在资源之上
	
	for point in points:
		border_line.add_point(world_pos + point)
	border_line.add_point(world_pos + points[0]) # 闭合
	
	add_child(border_line)

## 获取资源节点颜色
func _get_resource_node_color(resource_type: Enums.ResourceType) -> Color:
	match resource_type:
		Enums.ResourceType.GOLD:
			return Color(1.0, 0.84, 0.0) # 金色
		Enums.ResourceType.MANA:
			return Color(0.5, 0.2, 1.0) # 紫色
		Enums.ResourceType.FOOD:
			return Color(0.8, 0.6, 0.4) # 棕色
		_:
			return Color.WHITE

## 渲染单位
func _render_units() -> void:
	if not _unit_manager:
		return
	
	var units = _unit_manager.get_all_units()
	for unit in units:
		_create_unit_visual(unit)

## 创建单位可视化节点
func _create_unit_visual(unit: Unit) -> void:
	var world_pos = unit.get_world_position(_tile_size)
	
	# 获取单位图片路径
	var texture_path = _get_unit_texture_path(unit)
	
	if texture_path:
		# 使用图片渲染
		var sprite = Sprite2D.new()
		sprite.position = world_pos
		
		# 加载纹理
		var texture = load(texture_path)
		if texture:
			sprite.texture = texture
			# 调整大小以适应瓦块（可选：保持原始大小或缩放）
			var scale_factor = float(_tile_size.x) / float(texture.get_width()) * 0.8 # 80%瓦块大小
			sprite.scale = Vector2(scale_factor, scale_factor)
		else:
			push_warning("Failed to load texture: %s" % texture_path)
			# 如果加载失败，使用颜色圆形作为后备
			_create_unit_fallback_visual(unit, world_pos)
			return
		
		add_child(sprite)
	else:
		# 如果没有图片，使用颜色圆形作为后备
		_create_unit_fallback_visual(unit, world_pos)

## 获取单位纹理路径
func _get_unit_texture_path(unit: Unit) -> String:
	if unit is Goblin:
		return "res://img/Monster/哥布林.png"
	# 其他单位类型在后续阶段添加
	return ""

## 创建单位后备可视化（当图片不可用时）
func _create_unit_fallback_visual(unit: Unit, world_pos: Vector2) -> void:
	var radius = float(_tile_size.x) * 0.25 # 圆形半径为瓦块大小的25%
	
	# 根据单位类型和阵营选择颜色
	var color = _get_unit_color(unit)
	
	# 使用Polygon2D创建圆形
	var polygon = Polygon2D.new()
	polygon.color = color
	polygon.position = world_pos
	
	# 生成圆形顶点（16边形近似圆形）
	var points: PackedVector2Array = []
	var segments = 16
	for i in range(segments + 1):
		var angle = (float(i) / float(segments)) * TAU
		var point = Vector2(cos(angle) * radius, sin(angle) * radius)
		points.append(point)
	
	polygon.polygon = points
	add_child(polygon)
	
	# 创建边框
	var border_line = Line2D.new()
	border_line.width = 1.5
	border_line.default_color = Color.BLACK
	
	for point in points:
		border_line.add_point(world_pos + point)
	border_line.add_point(world_pos + points[0]) # 闭合
	
	add_child(border_line)

## 获取单位颜色（后备方案）
func _get_unit_color(unit: Unit) -> Color:
	match unit.faction:
		Enums.Faction.PLAYER:
			if unit is Goblin:
				return Color(0.2, 0.8, 0.2) # 绿色 = 哥布林（玩家）
			else:
				return Color(0.3, 0.7, 0.3) # 浅绿色 = 其他玩家单位
		Enums.Faction.ENEMY:
			return Color(0.8, 0.2, 0.2) # 红色 = 敌人
		Enums.Faction.NEUTRAL:
			return Color(0.7, 0.7, 0.7) # 灰色 = 中立
		_:
			return Color.WHITE
