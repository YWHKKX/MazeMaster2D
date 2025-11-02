extends Node2D

## 主场景脚本
## 初始化所有管理器，生成地图，设置渲染

var terrain_manager: TerrainManager
var cavity_manager: CavityManager
var tile_manager: TileManager
var map_generator: MapGenerator
var pathfinding_manager: PathfindingManager

var _start_point: Vector2i = Vector2i(-1, -1)  # 寻路起点

@onready var terrain_renderer = $World/TerrainRenderer
@onready var cavity_visualizer = $World/CavityVisualizer
@onready var path_visualizer = $World/PathVisualizer
@onready var regenerate_button = $UI/VBoxContainer/RegenerateButton
@onready var info_label = $UI/VBoxContainer/InfoLabel

func _ready():
	# 初始化管理器
	terrain_manager = TerrainManager.new()
	terrain_manager.initialize()
	
	cavity_manager = CavityManager.get_instance()
	
	tile_manager = TileManager.new()
	tile_manager.initialize()
	
	# 设置瓦块大小（用于坐标转换）- 增大瓦块尺寸
	var tile_size = Vector2(32, 32)
	tile_manager.SetTileSize(tile_size)
	
	# 创建地图生成器
	map_generator = MapGenerator.new(terrain_manager, cavity_manager)
	
	# 初始化寻路管理器
	pathfinding_manager = PathfindingManager.new()
	pathfinding_manager.initialize()
	pathfinding_manager.setup(tile_manager)
	
	# 设置渲染器
	terrain_renderer.setup(terrain_manager, tile_size)
	cavity_visualizer.setup(cavity_manager, tile_size)
	path_visualizer.setup(tile_size)
	
	# 连接按钮信号
	regenerate_button.pressed.connect(_on_regenerate_pressed)
	
	# 生成初始地图
	generate_map()

## 生成地图
func generate_map() -> void:
	# 生成地图
	map_generator.GenerateMap()
	
	# 同步TerrainManager的地形数据到TileManager
	var terrain_data = terrain_manager.GetTerrainData()
	tile_manager.InitializeTiles(
		terrain_manager.GetWidth(), 
		terrain_manager.GetHeight(), 
		terrain_data
	)
	
	# 渲染地形和空洞
	terrain_renderer.render_terrain()
	cavity_visualizer.render_cavities()
	
	# 更新寻路网格通行性
	pathfinding_manager.update_walkability()
	
	# 清除路径显示
	path_visualizer.clear_path()
	_start_point = Vector2i(-1, -1)
	
	# 更新信息显示
	_update_info()

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
			# 获取鼠标位置（世界坐标）
			var world_pos = get_global_mouse_position()
			
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
