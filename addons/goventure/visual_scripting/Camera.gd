extends Camera2D

var relative_speed = 0.5
var speed = 50
var zoom_scale = 1.02
var max_zoom = 4.0
var min_zoom = 0.25

var relative_collision_width = 0.04
var collision_width : int = 20
var relative_collision_height = 0.04
var collision_height : int = 20

var relative_buttons_heigth = 1.0
var button_heigth = 20
var relative_buttons_width = 0.2
var button_width = 20

var mouse_drag_start_pos
var cam_drag_start_pos
var is_dragged = false

var moving_up = false
var moving_down = false
var moving_left = false
var moving_right = false

@export var button_container : Control
@onready var up_collision = $Up/CollisionShape2D
@onready var down_collision = $Down/CollisionShape2D
@onready var left_collision = $Left/CollisionShape2D
@onready var right_collision = $Right/CollisionShape2D


func _ready():
	get_tree().get_root().size_changed.connect(update_move_rects)


func _input(event):
	if event.is_action_pressed("zoom_in"):
		zoom *= zoom_scale
	elif event.is_action_pressed("zoom_out"):
		zoom /= zoom_scale
	elif event.is_action("drag_camera"):
		if event.is_pressed():
			mouse_drag_start_pos = event.position
			cam_drag_start_pos = position
			is_dragged = true
		else:
			is_dragged = false
	elif event is InputEventMouseMotion and is_dragged:
		position = cam_drag_start_pos + zoom * (mouse_drag_start_pos - event.position)
	else:
		return
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)


func _process(delta):
	if not (moving_up or moving_down or moving_left or moving_right) and \
		not (Input.is_action_pressed("camera_up") or \
		Input.is_action_pressed("camera_down") or \
		Input.is_action_pressed("camera_left") or \
		Input.is_action_pressed("camera_right")):
		return
	
	if moving_up or Input.is_action_pressed("camera_up"):
		position.y -= speed * delta
	elif moving_down or Input.is_action_pressed("camera_down"):
		position.y += speed * delta
	if moving_left or Input.is_action_pressed("camera_left"):
		position.x -= speed * delta
	elif moving_right or Input.is_action_pressed("camera_right"):
		position.x += speed * delta
	
	
func update_move_rects():
	var ctrans = get_canvas_transform()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	collision_width = view_size.x * relative_collision_width
	collision_height = view_size.y * relative_collision_height
	
	button_width = view_size.x * relative_buttons_width
	button_heigth = view_size.y * relative_buttons_heigth
	
	speed = min(view_size.x, view_size.y) * relative_speed
	
	up_collision.global_position = Vector2(max_pos.x - view_size.x / 2, min_pos.y + collision_height / 2)
	up_collision.shape.extents = Vector2(view_size.x, collision_height)
	down_collision.global_position = Vector2(max_pos.x - view_size.x / 2, max_pos.y - collision_height / 2)
	down_collision.shape.extents = Vector2(view_size.x, collision_height)
	
	left_collision.global_position = Vector2(min_pos.x + collision_width / 2, max_pos.y - view_size.y / 2)
	left_collision.shape.extents = Vector2(collision_width, view_size.y)
	right_collision.global_position = Vector2(max_pos.x - collision_width / 2, max_pos.y - view_size.y / 2)
	right_collision.shape.extents = Vector2(collision_width, view_size.y)


func _on_Up_mouse_entered():
	moving_up = true


func _on_Up_mouse_exited():
	moving_up = false


func _on_Down_mouse_entered():
	moving_down = true


func _on_Down_mouse_exited():
	moving_down = false


func _on_Left_mouse_entered():
	moving_left = true


func _on_Left_mouse_exited():
	moving_left = false


func _on_Right_mouse_entered():
	moving_right = true


func _on_Right_mouse_exited():
	moving_right = false


func _on_Cables_active_cable_value_changed(is_active):
	set_edge_move_mode(is_active)


func _on_vs_nodes_drag_toggled(value):
	set_edge_move_mode(value)


func set_edge_move_mode(active):
	if active:
		button_container.hide()
	else:
		button_container.show()
	$Up.input_pickable = active
	$Down.input_pickable = active
	$Left.input_pickable = active
	$Right.input_pickable = active


func restore_configs(configs: Dictionary):
	global_position = configs["position"]
	zoom = configs["zoom"]
	zoom_scale = configs["zoom_scale"]


func serialize() -> Dictionary:
	return {
		"camera_configs": {
			"position": global_position,
			"zoom": zoom,
			"zoom_scale": zoom_scale
		}
	}
