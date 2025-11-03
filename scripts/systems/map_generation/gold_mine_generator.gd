extends RefCounted
class_name GoldMineGenerator

## 金矿生成器
## 在功能空洞中生成金矿

var _tile_manager: TileManager
var _entity_manager: EntityManager
var _resource_node_manager: ResourceNodeManager

## 初始化
func _init(tile_mgr: TileManager, entity_mgr: EntityManager, resource_node_mgr: ResourceNodeManager):
	_tile_manager = tile_mgr
	_entity_manager = entity_mgr
	_resource_node_manager = resource_node_mgr

## 在指定空洞中生成金矿
## cavity: 空洞对象
## 返回：生成的金矿，如果失败返回 null
func generate_gold_mine_in_cavity(cavity: Cavity) -> GoldMine:
	if cavity.positions.is_empty():
		return null
	
	# 在空洞内随机选择可建造位置
	var candidate_positions: Array[Vector2i] = []
	for pos in cavity.positions:
		# 检查地形是否可建造
		var tile = _tile_manager.GetTile(pos)
		if tile and tile.is_buildable:
			# 检查是否已有实体
			if _entity_manager and not _entity_manager.has_entity_at_position(pos):
				candidate_positions.append(pos)
	
	if candidate_positions.is_empty():
		return null
	
	# 随机选择一个位置
	var random_pos = candidate_positions[randi() % candidate_positions.size()]
	
	# 生成实体ID
	var id = 0
	if _entity_manager:
		id = _entity_manager.generate_id()
	else:
		id = randi() % 1000000
	
	# 创建金矿
	var gold_mine = GoldMine.new(id, random_pos)
	
	# 注册到管理器
	if _resource_node_manager:
		_resource_node_manager.register_node(gold_mine)
	if _entity_manager:
		_entity_manager.register_entity(gold_mine)
	
	return gold_mine

## 在多个功能空洞中生成金矿
## cavities: 空洞数组
## max_per_cavity: 每个空洞最多生成的金矿数量（默认1）
func generate_gold_mines(cavities: Array[Cavity], max_per_cavity: int = 1) -> Array[GoldMine]:
	var gold_mines: Array[GoldMine] = []
	
	for cavity in cavities:
		# 每个空洞最多生成 max_per_cavity 个金矿
		var count = 0
		var attempts = 0
		while count < max_per_cavity and attempts < 10:  # 最多尝试10次
			var gold_mine = generate_gold_mine_in_cavity(cavity)
			if gold_mine:
				gold_mines.append(gold_mine)
				count += 1
			attempts += 1
	
	return gold_mines


