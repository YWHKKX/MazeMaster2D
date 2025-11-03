extends RefCounted
class_name StateContext

## 状态上下文
## 每个State实例独立存储自己的上下文数据
## 使用Dictionary存储键值对（string key -> Variant value）

var _data: Dictionary = {}

## 构造函数
func _init(initial_data: Dictionary = {}):
	_data = initial_data.duplicate()

## 设置上下文数据
## key: 数据键（字符串）
## value: 数据值（任意类型）
func set_data(key: String, value: Variant) -> void:
	_data[key] = value

## 获取上下文数据
## key: 数据键
## default: 如果键不存在时的默认值
## 返回: 数据值或默认值
func get_data(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)

## 检查是否包含指定键
## key: 数据键
## 返回: 如果包含该键则返回true
func has_data(key: String) -> bool:
	return _data.has(key)

## 移除上下文数据
## key: 数据键
func remove_data(key: String) -> void:
	_data.erase(key)

## 清空所有上下文数据
func clear() -> void:
	_data.clear()

## 获取所有数据（副本）
## 返回: 数据字典的副本
func get_all_data() -> Dictionary:
	return _data.duplicate()

## 合并其他上下文数据
## other_context: 其他上下文实例或Dictionary
func merge(other_context) -> void:
	if other_context is StateContext:
		var other_data = other_context.get_all_data()
		for key in other_data:
			_data[key] = other_data[key]
	elif other_context is Dictionary:
		for key in other_context:
			_data[key] = other_context[key]

