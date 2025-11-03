extends Node2D

## 主场景脚本
## 初始化所有管理器，生成地图，设置渲染

var terrain_manager: TerrainManager
var cavity_manager: CavityManager
var tile_manager: TileManager
var map_generator: MapGenerator
var pathfinding_manager: PathfindingManager

# 第四阶段：新增管理器
var entity_manager: EntityManager
var resource_manager: ResourceManager
var building_manager: BuildingManager
var resource_node_manager: ResourceNodeManager
var unit_manager: UnitManager

var _start_point: Vector2i = Vector2i(-1, -1) # 寻路起点

@onready var terrain_renderer = $World/TerrainRenderer
@onready var cavity_visualizer = $World/CavityVisualizer
@onready var path_visualizer = $World/PathVisualizer
@onready var entity_renderer = $World/EntityRenderer
@onready var camera: Camera2D = $Camera
@onready var regenerate_button = $UILayer/UI/VBoxContainer/RegenerateButton
@onready var info_label = $UILayer/UI/VBoxContainer/InfoLabel
@onready var resource_ui = $UILayer/ResourceUI

func _ready():
	# 初始化基础管理器
	terrain_manager = TerrainManager.new()
	terrain_manager.initialize()
	
	cavity_manager = CavityManager.get_instance()
	
	tile_manager = TileManager.new()
	tile_manager.initialize()
	
	# 第四阶段：初始化实体相关管理器
	entity_manager = EntityManager.new()
	entity_manager.initialize()
	
	resource_manager = ResourceManager.new()
	resource_manager.initialize()
	
	building_manager = BuildingManager.new()
	building_manager.initialize()
	
	resource_node_manager = ResourceNodeManager.new()
	resource_node_manager.initialize()
	
	unit_manager = UnitManager.new()
	unit_manager.initialize()
	
	# 设置瓦块大小（用于坐标转换）- 增大瓦块尺寸
	var tile_size = Vector2(32, 32)
	tile_manager.SetTileSize(tile_size)
	
	# 创建地图生成器
	map_generator = MapGenerator.new(terrain_manager, cavity_manager)
	
	# 设置实体管理器到地图生成器
	map_generator.set_entity_managers(tile_manager, entity_manager, building_manager, resource_node_manager)
	
	# 初始化寻路管理器
	pathfinding_manager = PathfindingManager.new()
	pathfinding_manager.initialize()
	pathfinding_manager.setup(tile_manager)
	
	# 设置渲染器
	terrain_renderer.setup(terrain_manager, tile_size)
	cavity_visualizer.setup(cavity_manager, tile_size)
	path_visualizer.setup(tile_size)
	
	# 第四阶段：设置实体渲染器
	if entity_renderer:
		var tile_size_i = Vector2i(int(tile_size.x), int(tile_size.y))
		entity_renderer.setup(entity_manager, building_manager, resource_node_manager, unit_manager, tile_size_i)
	
	# 将可视化器设置到地图生成器中，实现即时可视化
	map_generator.set_cavity_visualizer(cavity_visualizer)
	
	# 第四阶段：设置资源UI
	if resource_ui:
		resource_ui.setup(resource_manager)
	
	# 连接按钮信号
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	
	# 生成初始地图
	generate_map()
	
	# 设置相机初始位置到地图中心，初始缩放到合适大小以查看全貌
	if camera and camera is CameraController:
		camera.position = Vector2(3200, 3200) # 地图中心 (200*32/2)
		var initial_zoom = Vector2(0.15, 0.15)  # 初始缩放：可以看到大部分地图
		camera.set_target_zoom(initial_zoom)  # 使用公共方法设置，确保同步

## 生成地图
func generate_map() -> void:
	# 清空旧的可视化框（必须在生成前清空，因为生成器会立即添加新框）
	cavity_visualizer.clear_cavities()
	
	# 生成地图（会立即生成可视化框）
	map_generator.GenerateMap()
	
	# 同步TerrainManager的地形数据到TileManager
	var terrain_data = terrain_manager.GetTerrainData()
	tile_manager.InitializeTiles(
		terrain_manager.GetWidth(),
		terrain_manager.GetHeight(),
		terrain_data
	)
	
	# 渲染地形（空洞已在生成时渲染）
	terrain_renderer.render_terrain()
	
	# 第四阶段：渲染实体
	if entity_renderer:
		entity_renderer.render_entities()
	
	# 更新寻路网格通行性
	pathfinding_manager.update_walkability()
	
	# 清除路径显示
	path_visualizer.clear_path()
	_start_point = Vector2i(-1, -1)
	
	# 更新信息显示
	_update_info()
	
	# 第四阶段：刷新资源UI
	if resource_ui:
		resource_ui.refresh()

## 更新信息显示
func _update_info() -> void:
	var all_cavities = cavity_manager.GetAllCavities()
	var critical_count = 0
	var functional_count = 0
	var ecosystem_count = 0
	
	for cavity in all_cavities:
		match cavity.type:
			Enums.CavityType.CRITICAL:
				critical_count += 1
			Enums.CavityType.FUNCTIONAL:
				functional_count += 1
			Enums.CavityType.ECOSYSTEM:
				ecosystem_count += 1
	
	var info_text = "地图信息:\n"
	info_text += "空洞总数: %d\n" % all_cavities.size()
	info_text += "关键: %d\n" % critical_count
	info_text += "功能: %d\n" % functional_count
	info_text += "生态: %d" % ecosystem_count
	
	info_label.text = info_text

## 重新生成按钮回调
func _on_regenerate_pressed() -> void:
	generate_map()

## 鼠标输入处理
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			# 获取鼠标位置（考虑相机）
			var world_pos: Vector2
			if camera:
				world_pos = camera.get_global_mouse_position()
			else:
				world_pos = get_global_mouse_position()
			
			# 转换为网格坐标
			var grid_pos = tile_manager.WorldToGrid(world_pos)
			
			# 检查是否在有效范围内
			if not tile_manager.IsValidPosition(grid_pos.x, grid_pos.y):
				return
			
			# 检查是否可通行
			if not tile_manager.IsWalkable(grid_pos):
				# 点击了不可通行的位置，清除路径
				path_visualizer.clear_path()
				_start_point = Vector2i(-1, -1)
				return
			
			# 如果还没有起点，设置起点
			if _start_point.x < 0 or _start_point.y < 0:
				_start_point = grid_pos
				path_visualizer.set_start_point(_start_point)
			else:
				# 计算路径
				var path = pathfinding_manager.find_path(_start_point, grid_pos)
				
				# 显示路径
				path_visualizer.set_path(path)
				path_visualizer.set_end_point(grid_pos)
				
				# 重置起点为当前点击位置，以便下次点击时继续寻路
				_start_point = grid_pos
				path_visualizer.set_start_point(_start_point)
