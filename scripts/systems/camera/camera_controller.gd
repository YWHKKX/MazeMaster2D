extends Camera2D
class_name CameraController

## 相机控制器
## 实现WASD移动、滚轮缩放、边界限制和平滑跟随

# 相机移动速度
@export var move_speed: float = 400.0

# 缩放速度（影响滚轮灵敏度）
@export var zoom_speed: float = 0.01  # 单次滚轮的缩放增量（更小的值需要更多次滚动才能放大）

# 缩放平滑速度（插值速度）
@export var zoom_smooth_speed: float = 8.0  # 缩放平滑过渡速度

# 最小/最大缩放（扩大范围以支持查看全貌）
@export var min_zoom: float = 0.05  # 最小缩放：可以看到整个地图（6400/1280 ≈ 5倍，所以0.05 = 1/20）
@export var max_zoom: float = 3.0   # 最大缩放：可以放大查看细节

# 地图边界
@export var map_bounds: Rect2 = Rect2(0, 0, 6400, 6400)  # 200*32

# 目标缩放值（用于平滑缩放）
var _target_zoom: Vector2 = Vector2(1.0, 1.0)

func _ready():
	# 启用平滑跟随
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0
	# 初始化目标缩放
	_target_zoom = zoom

func _process(delta):
	# WASD 移动
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direction.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direction.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction.y -= 1
	
	# 移动速度需要根据缩放调整
	if direction.length() > 0:
		position += direction.normalized() * move_speed * delta / zoom.x
	
	# 边界限制
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.end.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.end.y)
	
	# 平滑缩放过渡
	if zoom != _target_zoom:
		zoom = zoom.lerp(_target_zoom, zoom_smooth_speed * delta)
		# 如果非常接近，直接设置（避免无限接近）
		if zoom.distance_to(_target_zoom) < 0.001:
			zoom = _target_zoom

func _input(event):
	# 鼠标滚轮缩放
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in():
	var new_zoom = _target_zoom + Vector2(zoom_speed, zoom_speed)
	_target_zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func zoom_out():
	var new_zoom = _target_zoom - Vector2(zoom_speed, zoom_speed)
	_target_zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

## 设置目标缩放（用于外部初始化）
func set_target_zoom(new_zoom: Vector2) -> void:
	_target_zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	zoom = _target_zoom  # 立即应用，避免延迟

