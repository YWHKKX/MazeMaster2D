extends RefCounted
class_name GoldMineGenerator

## 金矿生成器
## 在地图上任意可建造位置生成金矿瓦块

var _tile_manager: TileManager

## 初始化
func _init(tile_mgr: TileManager):
	_tile_manager = tile_mgr

## 在地图任意位置生成一个金矿瓦块
## 返回：生成的金矿瓦块位置，如果失败返回 null
func generate_gold_mine_random() -> Vector2i:
	if not _tile_manager:
		return Vector2i(-1, -1)
	
	# 获取地图大小
	var width = _tile_manager.GetWidth()
	var height = _tile_manager.GetHeight()
	
	# 收集所有可建造位置（且没有建筑或资源）
	var candidate_positions: Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			var pos = Vector2i(x, y)
			var tile = _tile_manager.GetTile(pos)
			if tile and tile.is_buildable:
				# 检查是否已有建筑或资源
				if not _tile_manager.HasBuilding(pos) and not _tile_manager.HasResource(pos):
					candidate_positions.append(pos)
	
	if candidate_positions.is_empty():
		return Vector2i(-1, -1)
	
	# 随机选择一个位置
	var random_pos = candidate_positions[randi() % candidate_positions.size()]
	
	# 创建金矿瓦块数据
	var gold_mine_tile = GoldMineTile.new()
	
	# 存储在Tile中
	_tile_manager.SetResourceTile(random_pos, gold_mine_tile)
	
	return random_pos

## 在地图上生成指定数量的金矿瓦块
## count: 要生成的金矿数量
## 返回：生成的金矿位置数组
func generate_gold_mines(count: int = 20) -> Array[Vector2i]:
	var gold_mine_positions: Array[Vector2i] = []
	var attempts = 0
	var max_attempts = count * 50  # 最多尝试次数
	
	while gold_mine_positions.size() < count and attempts < max_attempts:
		var pos = generate_gold_mine_random()
		if pos.x >= 0 and pos.y >= 0:  # 有效位置
			gold_mine_positions.append(pos)
		attempts += 1
	
	return gold_mine_positions


