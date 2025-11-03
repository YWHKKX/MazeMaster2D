extends Control
class_name UnitBestiary

## 单位图鉴UI面板
## 显示所有22种单位的图鉴信息，支持筛选和搜索
## 参考MazeMaster项目的CharacterBestiary设计

var _unit_database: UnitDatabase = null
var _is_open: bool = false
var _current_category: String = "功能类"  # 当前筛选分类
var _selected_unit_type: Enums.SpecificEntityType = -1  # 选中的单位类型
var _search_text: String = ""  # 搜索文本
var _filtered_units: Array[Enums.SpecificEntityType] = []  # 过滤后的单位列表
var _avatar_cache: Dictionary = {}  # 头像缓存 (unit_type -> Texture2D)
var _list_cache: Dictionary = {}  # 列表缓存 (category_search_key -> Array[Enums.SpecificEntityType])
var _last_category: String = ""  # 上次筛选分类
var _last_search: String = ""  # 上次搜索文本

## UI节点引用（可选，如果场景中没有则使用代码创建）
var background_panel: Panel = null
var sidebar: VBoxContainer = null
var content_area: VBoxContainer = null
var unit_list: VBoxContainer = null
var search_box: LineEdit = null
var category_buttons: HBoxContainer = null
var unit_details: VBoxContainer = null

## 初始化图鉴
## unit_database: 单位数据库实例
func setup(unit_database: UnitDatabase) -> void:
	_unit_database = unit_database
	visible = false
	_is_open = false
	_setup_ui()
	_refresh_unit_list()

## 设置UI（如果场景中没有UI节点，则创建基础UI）
func _setup_ui() -> void:
	# 尝试获取场景中的UI节点
	background_panel = get_node_or_null("BackgroundPanel")
	
	if not background_panel:
		# 创建基础UI结构
		background_panel = Panel.new()
		background_panel.name = "BackgroundPanel"
		add_child(background_panel)
		
		# 设置背景面板样式
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(0.1, 0.1, 0.1, 0.9)
		background_panel.add_theme_stylebox_override("panel", style_box)
		
		# 设置面板大小和位置（居中）
		background_panel.set_anchors_preset(Control.PRESET_CENTER)
		background_panel.custom_minimum_size = Vector2(1000, 700)
		
		# 创建标题
		var title_label = Label.new()
		title_label.text = "单位图鉴"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_size_override("font_size", 24)
		background_panel.add_child(title_label)
		
		# 创建关闭提示
		var hint_label = Label.new()
		hint_label.text = "按 B 键或 ESC 键关闭图鉴"
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.position = Vector2(0, 650)
		hint_label.custom_minimum_size = Vector2(1000, 50)
		background_panel.add_child(hint_label)

## 打开图鉴
func open() -> void:
	_is_open = true
	visible = true
	_refresh_unit_list()

## 关闭图鉴
func close() -> void:
	_is_open = false
	visible = false

## 切换图鉴开关状态
func toggle() -> void:
	if _is_open:
		close()
	else:
		open()

## 处理输入事件
## event: 输入事件
## 返回: 如果事件已被处理则返回true
func handle_input(event: InputEvent) -> bool:
	if not _is_open:
		return false
	
	if event is InputEventKey and event.pressed:
		# B键关闭图鉴
		if event.keycode == KEY_B:
			close()
			return true
		# ESC键关闭图鉴
		if event.keycode == KEY_ESCAPE:
			close()
			return true
	
	return false

## 获取图鉴是否打开
## 返回: 如果打开则返回true
func is_open() -> bool:
	return _is_open

## 刷新单位列表
func _refresh_unit_list() -> void:
	if not _unit_database:
		return
	
	# 检查缓存键（分类+搜索文本）
	var cache_key = "%s|%s" % [_current_category, _search_text]
	
	# 如果筛选条件未变化，且缓存存在，直接使用缓存
	if _current_category == _last_category and _search_text == _last_search:
		if _list_cache.has(cache_key):
			_filtered_units = _list_cache[cache_key]
			_update_ui_display()
			return
	
	# 计算过滤后的单位列表
	var filtered: Array[Enums.SpecificEntityType] = []
	
	# 根据分类获取单位列表
	if _current_category == "全部":
		filtered = _unit_database.get_all_unit_types()
	elif _current_category == "功能类":
		filtered = _unit_database.get_units_by_category("功能类")
	elif _current_category == "战斗类":
		filtered = _unit_database.get_units_by_category("战斗类")
	else:
		filtered = _unit_database.get_all_unit_types()
	
	# 应用搜索过滤
	if _search_text != "":
		var search_results = _unit_database.search_units(_search_text)
		# 取交集
		filtered = filtered.filter(func(unit_type): return search_results.has(unit_type))
	
	# 更新过滤结果和缓存
	_filtered_units = filtered
	_list_cache[cache_key] = filtered
	_last_category = _current_category
	_last_search = _search_text
	
	# 更新UI显示
	_update_ui_display()

## 更新UI显示
func _update_ui_display() -> void:
	if not background_panel:
		return
	
	# 获取或创建单位列表容器
	if not unit_list:
		unit_list = background_panel.get_node_or_null("UnitList")
		if not unit_list:
			unit_list = VBoxContainer.new()
			unit_list.name = "UnitList"
			unit_list.position = Vector2(20, 80)
			unit_list.custom_minimum_size = Vector2(200, 600)
			background_panel.add_child(unit_list)
	
	# 清空现有列表项
	for child in unit_list.get_children():
		child.queue_free()
	
	# 为每个过滤后的单位创建列表项
	for unit_type in _filtered_units:
		var unit_data = _unit_database.get_unit_data(unit_type)
		if not unit_data:
			continue
		
		# 创建列表项按钮
		var item_button = Button.new()
		item_button.text = unit_data.name
		item_button.custom_minimum_size = Vector2(180, 40)
		
		# 如果当前选中，高亮显示
		if unit_type == _selected_unit_type:
			item_button.modulate = Color(1.2, 1.2, 1.0)
		
		# 点击时选择该单位
		item_button.pressed.connect(func(): select_unit(unit_type))
		
		unit_list.add_child(item_button)

## 选择单位
## unit_type: 单位类型
func select_unit(unit_type: Enums.SpecificEntityType) -> void:
	_selected_unit_type = unit_type
	_update_unit_details()

## 更新单位详情显示
func _update_unit_details() -> void:
	if _selected_unit_type == -1:
		return
	
	var unit_data = _unit_database.get_unit_data(_selected_unit_type)
	if not unit_data:
		return
	
	# 获取或创建详情容器
	if not unit_details:
		unit_details = background_panel.get_node_or_null("UnitDetails")
		if not unit_details:
			unit_details = VBoxContainer.new()
			unit_details.name = "UnitDetails"
			unit_details.position = Vector2(240, 80)
			unit_details.custom_minimum_size = Vector2(740, 600)
			background_panel.add_child(unit_details)
	
	# 清空现有详情
	for child in unit_details.get_children():
		child.queue_free()
	
	# 创建头像和基本信息容器
	var avatar_container = HBoxContainer.new()
	avatar_container.custom_minimum_size = Vector2(740, 120)
	unit_details.add_child(avatar_container)
	
	# 头像（稍后实现）
	var avatar_image = TextureRect.new()
	avatar_image.name = "AvatarImage"
	avatar_image.custom_minimum_size = Vector2(100, 100)
	avatar_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	avatar_container.add_child(avatar_image)
	
	# 基本信息
	var basic_info = VBoxContainer.new()
	basic_info.custom_minimum_size = Vector2(630, 100)
	avatar_container.add_child(basic_info)
	
	# 单位名称
	var name_label = Label.new()
	name_label.text = unit_data.name
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	basic_info.add_child(name_label)
	
	# 分类和种族
	var category_label = Label.new()
	category_label.text = "分类: %s  |  种族: %s" % [unit_data.category, unit_data.race]
	category_label.add_theme_font_size_override("font_size", 18)
	category_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	basic_info.add_child(category_label)
	
	# 描述
	var description_label = Label.new()
	description_label.text = unit_data.description
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.custom_minimum_size = Vector2(740, 60)
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	unit_details.add_child(description_label)
	
	# 属性容器
	var attributes_container = VBoxContainer.new()
	attributes_container.name = "AttributesContainer"
	attributes_container.custom_minimum_size = Vector2(740, 300)
	unit_details.add_child(attributes_container)
	
	# 属性标题
	var attributes_title = Label.new()
	attributes_title.text = "属性"
	attributes_title.add_theme_font_size_override("font_size", 20)
	attributes_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	attributes_container.add_child(attributes_title)
	
	# 创建属性网格（两列）
	var attributes_grid = GridContainer.new()
	attributes_grid.columns = 2
	attributes_grid.custom_minimum_size = Vector2(740, 250)
	attributes_container.add_child(attributes_grid)
	
	# 添加所有9项属性
	_add_attribute_row(attributes_grid, "生命值", str(unit_data.max_health))
	_add_attribute_row(attributes_grid, "攻击力", str(unit_data.attack_power))
	_add_attribute_row(attributes_grid, "攻击冷却", "%.1f秒" % unit_data.attack_cooldown)
	_add_attribute_row(attributes_grid, "攻击范围", "%d像素" % unit_data.attack_range)
	_add_attribute_row(attributes_grid, "追击范围", "%d像素" % unit_data.pursuit_range)
	_add_attribute_row(attributes_grid, "护甲值", str(unit_data.armor_value))
	_add_attribute_row(attributes_grid, "体型大小", "%.1f" % unit_data.body_size)
	_add_attribute_row(attributes_grid, "移动速度", "%.2f瓦块/秒" % unit_data.move_speed)
	_add_attribute_row(attributes_grid, "攻击类型", "远程" if unit_data.is_ranged else "近战")
	
	# 工作流容器
	var workflows_container = VBoxContainer.new()
	workflows_container.name = "WorkflowsContainer"
	workflows_container.custom_minimum_size = Vector2(740, 100)
	unit_details.add_child(workflows_container)
	
	# 工作流标题
	var workflows_title = Label.new()
	workflows_title.text = "工作流"
	workflows_title.add_theme_font_size_override("font_size", 20)
	workflows_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	workflows_container.add_child(workflows_title)
	
	# 工作流列表
	var workflows_list = Label.new()
	if unit_data.workflows.is_empty():
		workflows_list.text = "暂无配置的工作流"
	else:
		workflows_list.text = ", ".join(unit_data.workflows)
	workflows_list.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	workflows_list.custom_minimum_size = Vector2(740, 60)
	workflows_list.add_theme_font_size_override("font_size", 14)
	workflows_list.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	workflows_container.add_child(workflows_list)
	
	# 更新头像
	_load_and_display_avatar(avatar_image, _selected_unit_type)

## 添加属性行到网格容器
## container: 网格容器
## label: 属性名称
## value: 属性值
func _add_attribute_row(container: GridContainer, label: String, value: String) -> void:
	var label_node = Label.new()
	label_node.text = label + ":"
	label_node.add_theme_font_size_override("font_size", 14)
	label_node.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label_node.custom_minimum_size = Vector2(200, 25)
	container.add_child(label_node)
	
	var value_node = Label.new()
	value_node.text = value
	value_node.add_theme_font_size_override("font_size", 14)
	value_node.add_theme_color_override("font_color", Color(1.0, 1.0, 0.9))
	value_node.custom_minimum_size = Vector2(540, 25)
	container.add_child(value_node)

## 设置筛选分类
## category: 分类名称
func set_category(category: String) -> void:
	_current_category = category
	_refresh_unit_list()

## 设置搜索文本
## text: 搜索文本
func set_search_text(text: String) -> void:
	_search_text = text
	_refresh_unit_list()

## 加载单位头像
## unit_type: 单位类型
## 返回: Texture2D或null（如果图片不存在）
func _load_unit_avatar(unit_type: Enums.SpecificEntityType) -> Texture2D:
	# 检查缓存
	if _avatar_cache.has(unit_type):
		return _avatar_cache[unit_type]
	
	# 获取单位数据以确定图片路径
	var unit_data = _unit_database.get_unit_data(unit_type)
	if not unit_data:
		return null
	
	# 根据单位名称映射到图片路径
	var image_path = _get_unit_image_path(unit_data.name)
	
	# 尝试加载图片
	var texture: Texture2D = null
	if ResourceLoader.exists(image_path):
		var resource = load(image_path)
		if resource is Texture2D:
			texture = resource
	
	# 如果加载失败，创建占位符纹理（白色方块）
	if not texture:
		texture = _create_placeholder_texture()
	
	# 存入缓存
	_avatar_cache[unit_type] = texture
	return texture

## 获取单位图片路径
## unit_name: 单位名称
## 返回: 图片资源路径
func _get_unit_image_path(unit_name: String) -> String:
	# 单位名称到图片文件名的映射
	var image_map = {
		"哥布林": "res://img/Monster/哥布林.png",
		"地精": "res://img/Monster/地精.png",
		"地精酒保": "res://img/Monster/地精酒保.png",
		"地精铁匠": "res://img/Monster/地精铁匠.png",
		"哥布林斥候": "res://img/Monster/哥布林斥候.png",
		"哥布林战士": "res://img/Monster/哥布林战士.png",
		"兽人": "res://img/Monster/兽人.png",
	}
	
	# 如果映射中存在，直接返回
	if image_map.has(unit_name):
		return image_map[unit_name]
	
	# 否则尝试通用路径：img/Monster/{单位名称}.png
	var default_path = "res://img/Monster/%s.png" % unit_name
	return default_path

## 创建占位符纹理（白色方块）
## 返回: 占位符纹理
func _create_placeholder_texture() -> Texture2D:
	# 创建一个简单的白色纹理作为占位符
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.5, 0.5, 0.5, 1.0))  # 灰色占位符
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

## 加载并显示头像到TextureRect
## avatar_image: TextureRect节点
## unit_type: 单位类型
func _load_and_display_avatar(avatar_image: TextureRect, unit_type: Enums.SpecificEntityType) -> void:
	if not avatar_image:
		return
	
	var texture = _load_unit_avatar(unit_type)
	if texture:
		avatar_image.texture = texture
	else:
		# 如果加载失败，显示占位符
		avatar_image.texture = _create_placeholder_texture()

