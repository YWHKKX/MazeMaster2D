extends RefCounted
class_name MapGenerator

## 地图生成器
## 负责整体地图生成流程

var _terrain_manager: TerrainManager
var _cavity_manager: CavityManager
var _cavity_generator: SimpleCavityGenerator
var _poisson_sampler: PoissonDiskSampling
var _cavity_visualizer: CavityVisualizer = null

# 实体生成相关（可选）
var _tile_manager: TileManager = null
var _entity_manager: EntityManager = null
var _building_manager: BuildingManager = null
var _resource_node_manager: ResourceNodeManager = null
var _gold_mine_generator: GoldMineGenerator = null
var _iron_ore_generator: IronOreGenerator = null
var _food_resource_generator: FoodResourceGenerator = null

# 地图尺寸
var map_width: int = 200
var map_height: int = 200

# 空洞生成参数（不同大小分类的基础尺寸）
# 关键空洞使用大空洞尺寸，确保足够大
var critical_cavity_size: Vector2i = Vector2i(10, 10) # 关键空洞：大尺寸
var functional_cavity_size: Vector2i = Vector2i(4, 4) # 功能空洞：已废弃，使用随机大小
var ecosystem_cavity_size: Vector2i = Vector2i(3, 3) # 生态空洞：已废弃，使用随机大小

# 空洞大小定义（增大尺寸以适配200x200地图）
var small_cavity_size: Vector2i = Vector2i(4, 4) # 小空洞：面积 16 (<= 30)
var medium_cavity_size: Vector2i = Vector2i(8, 8) # 中空洞：面积 64 (30 < area <= 100)
var large_cavity_size: Vector2i = Vector2i(12, 12) # 大空洞：面积 144 (> 100)

## 初始化
func _init(terrain_mgr: TerrainManager, cavity_mgr: CavityManager):
	_terrain_manager = terrain_mgr
	_cavity_manager = cavity_mgr
	_cavity_generator = SimpleCavityGenerator.new(terrain_mgr, cavity_mgr)
	_poisson_sampler = PoissonDiskSampling.new()

## 设置空洞可视化器（可选）
func set_cavity_visualizer(visualizer: CavityVisualizer) -> void:
	_cavity_visualizer = visualizer

## 设置管理器（用于生成瓦块和实体）
func set_entity_managers(tile_mgr: TileManager, entity_mgr: EntityManager = null, building_mgr: BuildingManager = null, resource_node_mgr: ResourceNodeManager = null) -> void:
	_tile_manager = tile_mgr
	_entity_manager = entity_mgr
	_building_manager = building_mgr
	_resource_node_manager = resource_node_mgr
	if _tile_manager:
		_gold_mine_generator = GoldMineGenerator.new(_tile_manager)
		_iron_ore_generator = IronOreGenerator.new(_tile_manager)
		_food_resource_generator = FoodResourceGenerator.new(_tile_manager)

## 生成完整地图
func GenerateMap() -> void:
	# 1. 初始化地形（全部未挖掘）
	_terrain_manager.InitializeTerrain(map_width, map_height, Enums.TerrainType.UNDUG)
	_cavity_manager.initialize()
	
	# 2. 生成关键空洞（地牢之心在中心）
	var critical_cavities = GenerateCriticalCavities()
	
	# 3. 生成功能空洞（泊松圆盘）- 增加数量以适应更大的地图
	var functional_cavities = GenerateFunctionalCavities(20, 15.0)
	
	# 4. 生成生态空洞（泊松圆盘）- 增加数量以适应更大的地图
	var ecosystem_cavities = GenerateEcosystemCavities(15, 18.0)
	
	# 5. 同步地形数据到 TileManager（为实体生成做准备）
	# 必须在生成实体之前同步，确保空洞位置的 is_buildable 属性正确
	if _tile_manager:
		var terrain_data = _terrain_manager.GetTerrainData()
		_tile_manager.InitializeTiles(map_width, map_height, terrain_data)
	
	# 6. 生成实体（地牢之心和金矿瓦块）
	if _tile_manager:
		GenerateEntities(critical_cavities, functional_cavities)
	
	# 6. 不生成连接通道（空洞独立存在，不需要通路）
	# _connect_all_cavities(critical_cavities + functional_cavities + ecosystem_cavities)

## 根据大小分类随机选择大小
## 返回值为 Vector2i，概率：小50%、中30%、大20%
func _roll_cavity_size() -> Vector2i:
	var roll = randf()
	if roll < 0.5:
		return small_cavity_size
	elif roll < 0.8:
		return medium_cavity_size
	else:
		return large_cavity_size

## 生成关键空洞
func GenerateCriticalCavities() -> Array[Cavity]:
	var cavities: Array[Cavity] = []
	
	# 地牢之心在地图中心（使用矩形，使用大空洞尺寸）
	var center = Vector2i(map_width / 2, map_height / 2)
	var dungeon_heart = _cavity_generator.GenerateRectangularCavity(
		center,
		large_cavity_size, # 关键空洞使用大空洞尺寸，确保足够大
		Enums.CavityType.CRITICAL
	)
	if dungeon_heart:
		cavities.append(dungeon_heart)
		# 立即生成可视化框
		if _cavity_visualizer:
			_cavity_visualizer.draw_cavity_immediately(dungeon_heart)
	
	# 其他关键建筑（传送门、英雄营地）随机位置
	# 这里暂时只生成地牢之心，其他关键建筑后续添加
	
	return cavities

## 生成功能空洞
func GenerateFunctionalCavities(count: int, min_distance: float) -> Array[Cavity]:
	var cavities: Array[Cavity] = []
	var bounds = Rect2i(0, 0, map_width, map_height)
	
	# 使用泊松圆盘算法生成中心点
	var centers = _poisson_sampler.GeneratePoints(min_distance, 30, bounds)
	
	# 限制数量
	var actual_count = min(count, centers.size())
	
	for i in range(actual_count):
		var center = Vector2i(centers[i].x, centers[i].y)
		# 随机选择大小（概率控制：小50%、中30%、大20%）
		var random_size = _roll_cavity_size()
		# 随机选择形状（优先使用噪声形状，参考 MazeMaster3D）
		var shape_types = [
			SimpleCavityGenerator.CavityShape.NOISE,
			SimpleCavityGenerator.CavityShape.ORGANIC,
			SimpleCavityGenerator.CavityShape.ORGANIC,
			SimpleCavityGenerator.CavityShape.NOISE
		] # 增加有机形状权重
		var random_shape = shape_types[randi() % shape_types.size()]
		var cavity = _cavity_generator.GenerateCavity(
			center,
			random_size,
			Enums.CavityType.FUNCTIONAL,
			random_shape as int
		)
		if cavity:
			cavities.append(cavity)
			# 立即生成可视化框
			if _cavity_visualizer:
				_cavity_visualizer.draw_cavity_immediately(cavity)
	
	return cavities

## 生成生态空洞
func GenerateEcosystemCavities(count: int, min_distance: float) -> Array[Cavity]:
	var cavities: Array[Cavity] = []
	var bounds = Rect2i(0, 0, map_width, map_height)
	
	# 使用泊松圆盘算法生成中心点
	var centers = _poisson_sampler.GeneratePoints(min_distance, 30, bounds)
	
	# 限制数量
	var actual_count = min(count, centers.size())
	
	for i in range(actual_count):
		var center = Vector2i(centers[i].x, centers[i].y)
		# 随机选择大小（概率控制：小50%、中30%、大20%）
		var random_size = _roll_cavity_size()
		# 随机选择形状（优先使用噪声形状，参考 MazeMaster3D）
		var shape_types = [
			SimpleCavityGenerator.CavityShape.NOISE,
			SimpleCavityGenerator.CavityShape.ORGANIC,
			SimpleCavityGenerator.CavityShape.ORGANIC,
			SimpleCavityGenerator.CavityShape.NOISE
		] # 增加有机形状权重
		var random_shape = shape_types[randi() % shape_types.size()]
		var cavity = _cavity_generator.GenerateCavity(
			center,
			random_size,
			Enums.CavityType.ECOSYSTEM,
			random_shape as int
		)
		if cavity:
			cavities.append(cavity)
			# 立即生成可视化框
			if _cavity_visualizer:
				_cavity_visualizer.draw_cavity_immediately(cavity)
	
	return cavities

## 生成实体（地牢之心和金矿瓦块）
func GenerateEntities(critical_cavities: Array[Cavity], functional_cavities: Array[Cavity]) -> void:
	# 生成地牢之心（在关键空洞中心，作为建筑瓦块）
	for cavity in critical_cavities:
		if cavity.type == Enums.CavityType.CRITICAL:
			_generate_dungeon_heart(cavity)
	
	# 生成资源瓦块（在地图任意可建造位置）
	if _gold_mine_generator:
		_gold_mine_generator.generate_gold_mines(20) # 生成20个金矿瓦块
	if _iron_ore_generator:
		_iron_ore_generator.generate_iron_ores(15) # 生成15个铁矿瓦块
	if _food_resource_generator:
		_food_resource_generator.generate_food_resources(12) # 生成12个食物资源瓦块

## 生成地牢之心（作为建筑瓦块）
func _generate_dungeon_heart(cavity: Cavity) -> void:
	if not _tile_manager:
		return
	
	# 地牢之心放在空洞中心
	var center_position = cavity.center
	
	# 地牢之心大小 3x3
	var building_size = Vector2i(3, 3)
	
	# 调整位置，使建筑左上角在合适位置（中心减去一半大小）
	var start_position = center_position - Vector2i(building_size.x / 2, building_size.y / 2)
	
	# 检查是否可以放置（所有位置必须是可建造的且没有建筑或资源）
	var can_place = true
	for x in range(building_size.x):
		for y in range(building_size.y):
			var pos = start_position + Vector2i(x, y)
			if not _tile_manager.IsValidPosition(pos.x, pos.y):
				can_place = false
				break
			if not _tile_manager.IsBuildable(pos):
				can_place = false
				break
			if _tile_manager.HasBuilding(pos) or _tile_manager.HasResource(pos):
				can_place = false
				break
		if not can_place:
			break
	
	if can_place:
		# 创建地牢之心瓦块数据
		var dungeon_heart_tile = DungeonHeartTile.new()
		
		# 将建筑数据存储在每个被占用的Tile中
		for x in range(building_size.x):
			for y in range(building_size.y):
				var pos = start_position + Vector2i(x, y)
				_tile_manager.SetBuildingTile(pos, dungeon_heart_tile)
	else:
		push_warning("MapGenerator: Cannot place dungeon heart at cavity center (%d, %d)" % [center_position.x, center_position.y])

## 连接所有空洞
func _connect_all_cavities(cavities: Array[Cavity]) -> void:
	if cavities.size() <= 1:
		return
	
	# 简单策略：将每个空洞连接到最近的另一个空洞
	var connected = [0] # 已连接的索引
	var unconnected = []
	for i in range(1, cavities.size()):
		unconnected.append(i)
	
	# 连接所有未连接的空洞到已连接的网络
	while not unconnected.is_empty():
		var best_to = -1
		var best_from = -1
		var best_dist = INF
		
		for from_idx in unconnected:
			var from_cavity = cavities[from_idx]
			for to_idx in connected:
				var to_cavity = cavities[to_idx]
				var dist = from_cavity.center.distance_to(to_cavity.center)
				if dist < best_dist:
					best_dist = dist
					best_from = from_idx
					best_to = to_idx
		
		if best_from >= 0 and best_to >= 0:
			GenerateConnectingChannels(cavities[best_from], cavities[best_to])
			connected.append(best_from)
			unconnected.erase(best_from)

## 生成连接通道
func GenerateConnectingChannels(from_cavity: Cavity, to_cavity: Cavity) -> void:
	# 使用 Bresenham 算法生成通道
	var line_points = BresenhamLine.GetLinePoints(from_cavity.center, to_cavity.center)
	
	# 确保通道宽度至少为2格（允许双向通行）
	var channel_width = 2
	var half_width = int(channel_width / 2)
	
	for point in line_points:
		# 挖掘通道及其周围的格子
		for dx in range(-half_width, half_width + 1):
			for dy in range(-half_width, half_width + 1):
				var channel_pos = Vector2i(point.x + dx, point.y + dy)
				if _terrain_manager.IsValidPosition(channel_pos.x, channel_pos.y):
					_terrain_manager.SetTerrainType(
						channel_pos.x,
						channel_pos.y,
						Enums.TerrainType.DUG
					)
