extends BaseManager
class_name CavityManager

## 空洞管理器（单例）
## 负责空洞的注册、查找、更新

static var instance: CavityManager = null

var _cavities: Dictionary = {}  # id -> Cavity
var _next_id: int = 0

## 获取单例实例
static func get_instance() -> CavityManager:
	if instance == null:
		instance = CavityManager.new()
		instance.initialize()
	return instance

## 初始化
func _initialize() -> void:
	_cavities.clear()
	_next_id = 0

## 清理
func _cleanup() -> void:
	_cavities.clear()
	_next_id = 0

## 注册空洞
func RegisterCavity(cavity: Cavity) -> void:
	if _cavities.has(cavity.id):
		push_warning("Cavity ID already exists: %d" % cavity.id)
		return
	
	_cavities[cavity.id] = cavity

## 获取下一个可用ID
func GetNextId() -> int:
	var id = _next_id
	_next_id += 1
	return id

## 按类型查找空洞
func GetCavitiesOfType(type: Enums.CavityType) -> Array[Cavity]:
	var result: Array[Cavity] = []
	for cavity in _cavities.values():
		if cavity.type == type:
			result.append(cavity)
	return result

## 获取所有空洞
func GetAllCavities() -> Array[Cavity]:
	var result: Array[Cavity] = []
	for cavity in _cavities.values():
		result.append(cavity)
	return result

## 更新空洞
func UpdateCavity(id: int, updated_cavity: Cavity) -> void:
	if not _cavities.has(id):
		push_warning("Cavity ID not found: %d" % id)
		return
	
	_cavities[id] = updated_cavity

## 获取空洞
## 如果不存在，返回 null
func GetCavity(id: int) -> Cavity:
	if _cavities.has(id):
		return _cavities[id]
	return null

## 移除空洞
func RemoveCavity(id: int) -> void:
	_cavities.erase(id)

