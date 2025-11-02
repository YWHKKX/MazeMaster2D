extends RefCounted
class_name MapGenerator

## 地图生成器
## 负责整体地图生成流程

var _terrain_manager: TerrainManager
var _cavity_manager: CavityManager
var _cavity_generator: SimpleCavityGenerator
var _poisson_sampler: PoissonDiskSampling
var _cavity_visualizer: CavityVisualizer = null

# 地图尺寸
var map_width: int = 200
var map_height: int = 200

# 空洞生成参数（不同大小分类的基础尺寸）
var critical_cavity_size: Vector2i = Vector2i(5, 5)
var functional_cavity_size: Vector2i = Vector2i(4, 4)
var ecosystem_cavity_size: Vector2i = Vector2i(3, 3)

# 空洞大小定义
var small_cavity_size: Vector2i = Vector2i(3, 3)  # 小空洞：面积 <= 12
var medium_cavity_size: Vector2i = Vector2i(5, 5)  # 中空洞：12 < 面积 <= 30
var large_cavity_size: Vector2i = Vector2i(8, 8)   # 大空洞：面积 > 30

## 初始化
func _init(terrain_mgr: TerrainManager, cavity_mgr: CavityManager):
	_terrain_manager = terrain_mgr
	_cavity_manager = cavity_mgr
	_cavity_generator = SimpleCavityGenerator.new(terrain_mgr, cavity_mgr)
	_poisson_sampler = PoissonDiskSampling.new()

## 设置空洞可视化器（可选）
func set_cavity_visualizer(visualizer: CavityVisualizer) -> void:
	_cavity_visualizer = visualizer

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
	
	# 5. 不生成连接通道（空洞独立存在，不需要通路）
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
	
	# 地牢之心在地图中心（使用矩形）
	var center = Vector2i(map_width / 2, map_height / 2)
	var dungeon_heart = _cavity_generator.GenerateRectangularCavity(
		center,
		critical_cavity_size,
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
		]  # 增加有机形状权重
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
		]  # 增加有机形状权重
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

## 连接所有空洞
func _connect_all_cavities(cavities: Array[Cavity]) -> void:
	if cavities.size() <= 1:
		return
	
	# 简单策略：将每个空洞连接到最近的另一个空洞
	var connected = [0]  # 已连接的索引
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

