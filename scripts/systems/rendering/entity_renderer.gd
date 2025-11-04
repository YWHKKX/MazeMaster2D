extends Node2D
class_name EntityRenderer

## 实体渲染器
## 使用子节点渲染所有实体（建筑瓦块、资源瓦块、单位）

var _tile_manager: TileManager = null
var _unit_manager: UnitManager = null
var _tile_size: Vector2i = Vector2i(32, 32)

# 用于跟踪已渲染的建筑（避免重复渲染多格建筑）
var _rendered_buildings: Dictionary = {}

# 状态可视化器字典（unit_id -> StateVisualizer）
var _state_visualizers: Dictionary = {}

## 初始化
func setup(tile_mgr: TileManager, unit_mgr: UnitManager, tile_size: Vector2i = Vector2i(32, 32)) -> void:
	_tile_manager = tile_mgr
	_unit_manager = unit_mgr
	_tile_size = tile_size
	
	# 设置 z_index 确保 EntityRenderer 及其子节点渲染在地形之上
	z_index = 10

## 渲染所有实体
func render_entities() -> void:
	# 清空建筑和资源渲染（但保留状态可视化器）
	_clear_rendered_entities()
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

## 更新状态可视化（每帧调用）
## delta: 帧时间间隔
## 注意：这个方法需要在Main.gd的_process中调用，以实时更新状态可视化
func update_state_visualizations(delta: float) -> void:
	if not _unit_manager:
		return
	
	# 获取工作流管理器
	var workflow_manager = _unit_manager.get_workflow_manager()
	
	var units = _unit_manager.get_all_units()
	for unit in units:
		# 确保每个单位都有状态可视化器（如果单位有状态机）
		var state_machine = _unit_manager.get_state_machine(unit.id)
		if state_machine:
			if not _state_visualizers.has(unit.id):
				var visualizer = StateVisualizer.new()
				visualizer.setup(unit.id, state_machine, workflow_manager)
				_state_visualizers[unit.id] = visualizer
				add_child(visualizer)
			else:
				# 如果已经存在但WorkflowManager引用可能变化，更新它
				var visualizer = _state_visualizers[unit.id]
				if visualizer and workflow_manager:
					# StateVisualizer没有set_workflow_manager方法，需要在setup时传递
					# 这里重新setup以更新引用（如果workflow_manager变化）
					visualizer.setup(unit.id, state_machine, workflow_manager)
			
			# 更新状态可视化器
			var visualizer = _state_visualizers[unit.id]
			var world_pos = unit.get_world_position(_tile_size)
			visualizer.update_visualization(delta, world_pos)

## 清空所有渲染（包括状态可视化器）
func clear() -> void:
	_clear_rendered_entities()
	# 清理状态可视化器字典
	_state_visualizers.clear()

## 清空实体渲染（但保留状态可视化器）
func _clear_rendered_entities() -> void:
	var children_to_remove = []
	for child in get_children():
		# 只删除非状态可视化器的节点
		if not (child is StateVisualizer):
			children_to_remove.append(child)
	
	for child in children_to_remove:
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
	return pos # 简化实现，假设pos就是左上角

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
	fill_rect.color.a = 0.3 # 半透明填充
	fill_rect.z_index = 10 # 确保建筑显示在地形之上
	add_child(fill_rect)
	
	# 创建Line2D节点用于边框
	var border_line = Line2D.new()
	border_line.width = 3.0
	border_line.default_color = color
	border_line.z_index = 11 # 边框在建筑填充之上
	
	var points = [
		world_pos,
		Vector2(world_pos.x + world_size.x, world_pos.y),
		Vector2(world_pos.x + world_size.x, world_pos.y + world_size.y),
		Vector2(world_pos.x, world_pos.y + world_size.y),
		world_pos # 闭合
	]
	
	for point in points:
		border_line.add_point(point)
	
	add_child(border_line)

## 获取建筑颜色
func _get_building_color(building_data: BuildingTile) -> Color:
	if building_data is DungeonHeartTile:
		return Color(0.8, 0.2, 0.2) # 深红色 = 地牢之心
	else:
		return Color(0.6, 0.4, 0.2) # 棕色 = 其他建筑

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
	
	# 使用像素艺术生成器创建纹理
	var pixel_art_generator = PixelArtGenerator.new()
	var image = pixel_art_generator.create_resource_tile_image(resource_data.resource_type, _tile_size)
	
	# 创建 ImageTexture
	var image_texture = ImageTexture.create_from_image(image)
	
	# 使用 Sprite2D 节点渲染资源瓦块（更适合像素艺术）
	# 注意：项目设置 → 渲染 → 纹理 → 默认纹理过滤应设置为 "Nearest" 以保持像素清晰
	# 如果项目设置已配置为 Nearest，则不需要额外设置材质
	var sprite = Sprite2D.new()
	# Sprite2D 默认以纹理中心对齐，world_pos 是左上角
	# 需要将 position 设置为纹理中心位置（左上角 + 瓦块大小的一半）
	sprite.position = world_pos + Vector2(_tile_size.x / 2.0, _tile_size.y / 2.0)
	sprite.texture = image_texture
	sprite.z_index = 10 # 确保资源显示在地形之上
	
	# 在 Godot 4 中，纹理过滤主要通过项目设置控制
	# 重要：必须在项目设置中配置默认纹理过滤为 "Nearest" 以保持像素清晰
	# 项目设置路径：项目 → 项目设置 → 渲染 → 纹理 → 默认纹理过滤 → 设置为 "Nearest"
	# 如果项目设置已配置，则不需要代码设置材质
	
	add_child(sprite)
	
	# 创建边框（使用Line2D）- 矩形边框
	var border_line = Line2D.new()
	border_line.width = 2.0
	border_line.default_color = Color.BLACK
	border_line.z_index = 11 # 边框在资源之上
	
	# 矩形四个角点
	var points = [
		world_pos,
		Vector2(world_pos.x + _tile_size.x, world_pos.y),
		Vector2(world_pos.x + _tile_size.x, world_pos.y + _tile_size.y),
		Vector2(world_pos.x, world_pos.y + _tile_size.y),
		world_pos # 闭合
	]
	
	for point in points:
		border_line.add_point(point)
	
	add_child(border_line)
	
	# 注意：Area2D交互节点已移除
	# InteractionState目前使用距离判断而非Area2D检测
	# 如果将来需要Area2D交互，可以在此处重新添加ResourceInteractable节点

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
	
	# 第五阶段：创建状态可视化器（用于显示状态指示器 - 右上角空心矩形）
	# 注意：状态可视化器的创建和更新由 update_state_visualizations() 处理
	# 这里不需要重复创建，因为 render_entities() 每帧都会调用
	# 但需要确保状态可视化器在 update_state_visualizations() 中被正确更新
	
	# 获取单位图片路径
	var texture_path = _get_unit_texture_path(unit)
	
	if texture_path:
		# 使用图片渲染
		var sprite = Sprite2D.new()
		sprite.position = world_pos
		sprite.z_index = 15 # 单位显示在建筑/资源之上，但在状态指示器之下
		
		# 加载纹理
		var texture = load(texture_path)
		if texture:
			sprite.texture = texture
			# 调整大小以适应瓦块（可选：保持原始大小或缩放）
			var scale_factor = float(_tile_size.x) / float(texture.get_width()) * 0.8 # 80%瓦块大小
			sprite.scale = Vector2(scale_factor, scale_factor)
			
			# 单位保持原始颜色，不使用状态颜色调制
			# 状态指示器通过StateVisualizer独立绘制在右上角
			sprite.modulate = Color.WHITE
		else:
			push_warning("Failed to load texture: %s" % texture_path)
			# 如果加载失败，使用颜色圆形作为后备
			_create_unit_fallback_visual(unit, world_pos, Color.WHITE)
			return
		
		add_child(sprite)
	else:
		# 如果没有图片，使用颜色圆形作为后备
		_create_unit_fallback_visual(unit, world_pos, Color.WHITE)

## 获取单位纹理路径
func _get_unit_texture_path(unit: Unit) -> String:
	if unit is Goblin:
		return "res://img/Monster/哥布林.png"
	# 其他单位类型在后续阶段添加
	return ""

## 创建单位后备可视化（当图片不可用时）
## unit: 单位实例
## world_pos: 世界坐标位置
## status_color: 状态颜色（已弃用，单位保持原始颜色，状态通过右上角指示器显示）
func _create_unit_fallback_visual(unit: Unit, world_pos: Vector2, status_color: Color = Color.WHITE) -> void:
	var radius = float(_tile_size.x) * 0.25 # 圆形半径为瓦块大小的25%
	
	# 根据单位类型和阵营选择颜色（单位保持原始颜色，不混合状态颜色）
	var color = _get_unit_color(unit)
	# 注意：状态颜色现在通过StateVisualizer在右上角显示，不再影响单位本身颜色
	
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
