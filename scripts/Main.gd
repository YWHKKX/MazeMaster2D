extends Node2D

## 主场景脚本
## 初始化所有管理器，生成地图，设置渲染

var terrain_manager: TerrainManager
var cavity_manager: CavityManager
var tile_manager: TileManager
var map_generator: MapGenerator

@onready var terrain_renderer = $World/TerrainRenderer
@onready var cavity_visualizer = $World/CavityVisualizer
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
	
	# 设置渲染器
	terrain_renderer.setup(terrain_manager, tile_size)
	cavity_visualizer.setup(cavity_manager, tile_size)
	
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
