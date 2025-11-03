extends Node2D
class_name EntityRenderer

## 实体渲染器
## 使用简单的形状和颜色渲染所有实体（建筑、资源节点、单位）

var _entity_manager: EntityManager = null
var _building_manager: BuildingManager = null
var _resource_node_manager: ResourceNodeManager = null
var _unit_manager: UnitManager = null
var _tile_size: Vector2i = Vector2i(32, 32)

## 初始化
func setup(entity_mgr: EntityManager, building_mgr: BuildingManager, resource_node_mgr: ResourceNodeManager, unit_mgr: UnitManager, tile_size: Vector2i = Vector2i(32, 32)) -> void:
	_entity_manager = entity_mgr
	_building_manager = building_mgr
	_resource_node_manager = resource_node_mgr
	_unit_manager = unit_mgr
	_tile_size = tile_size

## 渲染所有实体
func render_entities() -> void:
	clear()
	
	if not _building_manager or not _building_manager.is_initialized():
		return
	
	if not _resource_node_manager or not _resource_node_manager.is_initialized():
		return
	
	if not _unit_manager or not _unit_manager.is_initialized():
		return
	
	# 渲染建筑
	_render_buildings()
	
	# 渲染资源节点
	_render_resource_nodes()
	
	# 渲染单位
	_render_units()

## 清空所有渲染
func clear() -> void:
	for child in get_children():
		child.queue_free()

## 渲染建筑
func _render_buildings() -> void:
	if not _building_manager:
		return
	
	var buildings = _building_manager.get_all_buildings()
	for building in buildings:
		_draw_building(building)

## 绘制单个建筑
func _draw_building(building: Building) -> void:
	var world_pos = building.get_world_position(_tile_size)
	var world_size = Vector2(building.size.x * _tile_size.x, building.size.y * _tile_size.y)
	
	# 根据建筑类型选择颜色
	var color = _get_building_color(building)
	
	# 使用 draw_rect 绘制建筑边界
	var rect = Rect2(world_pos, world_size)
	draw_rect(rect, color, false, 3.0)  # false = 不填充，3.0 = 线宽
	
	# 可选：绘制半透明填充
	var fill_color = color
	fill_color.a = 0.2
	draw_rect(rect, fill_color, true)

## 获取建筑颜色
func _get_building_color(building: Building) -> Color:
	if building is DungeonHeart:
		return Color(0.8, 0.2, 0.2)  # 深红色 = 地牢之心
	else:
		return Color(0.6, 0.4, 0.2)  # 棕色 = 其他建筑

## 渲染资源节点
func _render_resource_nodes() -> void:
	if not _resource_node_manager:
		return
	
	var nodes = _resource_node_manager.get_all_nodes()
	for node in nodes:
		_draw_resource_node(node)

## 绘制单个资源节点
func _draw_resource_node(node: ResourceNode) -> void:
	var world_pos = node.get_world_position(_tile_size)
	var radius = float(_tile_size.x) * 0.3  # 圆形半径为瓦块大小的30%
	
	# 根据资源类型选择颜色
	var color = _get_resource_node_color(node.resource_type)
	
	# 绘制圆形
	draw_circle(world_pos, radius, color)
	
	# 绘制边框
	draw_circle(world_pos, radius, Color.BLACK, false, 2.0)
	
	# 可选：显示资源数量文本
	if node.current_amount > 0:
		var text = str(node.current_amount)
		var font_size = 16
		# 注意：这里需要使用 Label 或自定义文本渲染，draw_string 需要字体
		# 暂时省略文本显示，后续可以添加

## 获取资源节点颜色
func _get_resource_node_color(resource_type: Enums.ResourceType) -> Color:
	match resource_type:
		Enums.ResourceType.GOLD:
			return Color(1.0, 0.84, 0.0)  # 金色
		Enums.ResourceType.MANA:
			return Color(0.5, 0.2, 1.0)  # 紫色
		Enums.ResourceType.FOOD:
			return Color(0.8, 0.6, 0.4)  # 棕色
		_:
			return Color.WHITE

## 渲染单位
func _render_units() -> void:
	if not _unit_manager:
		return
	
	var units = _unit_manager.get_all_units()
	for unit in units:
		_draw_unit(unit)

## 绘制单个单位
func _draw_unit(unit: Unit) -> void:
	var world_pos = unit.get_world_position(_tile_size)
	var radius = float(_tile_size.x) * 0.25  # 圆形半径为瓦块大小的25%
	
	# 根据单位类型和阵营选择颜色
	var color = _get_unit_color(unit)
	
	# 绘制圆形
	draw_circle(world_pos, radius, color)
	
	# 绘制边框
	draw_circle(world_pos, radius, Color.BLACK, false, 1.5)

## 获取单位颜色
func _get_unit_color(unit: Unit) -> Color:
	match unit.faction:
		Enums.Faction.PLAYER:
			if unit is Goblin:
				return Color(0.2, 0.8, 0.2)  # 绿色 = 哥布林（玩家）
			else:
				return Color(0.3, 0.7, 0.3)  # 浅绿色 = 其他玩家单位
		Enums.Faction.ENEMY:
			return Color(0.8, 0.2, 0.2)  # 红色 = 敌人
		Enums.Faction.NEUTRAL:
			return Color(0.7, 0.7, 0.7)  # 灰色 = 中立
		_:
			return Color.WHITE

