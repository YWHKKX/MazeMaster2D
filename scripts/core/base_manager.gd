extends RefCounted
class_name BaseManager

## 管理器基类
## 提供统一的单例模式实现和初始化/清理接口

var _initialized: bool = false

## 初始化管理器（子类需要重写）
func _initialize() -> void:
	pass

## 清理管理器（子类需要重写）
func _cleanup() -> void:
	pass

## 检查是否已初始化
func is_initialized() -> bool:
	return _initialized

## 初始化（公共接口）
func initialize() -> void:
	if _initialized:
		push_warning("Manager already initialized: %s" % get_script().resource_path)
		return
	
	_initialize()
	_initialized = true

## 清理（公共接口）
func cleanup() -> void:
	if not _initialized:
		return
	
	_cleanup()
	_initialized = false

