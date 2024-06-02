class_name Cable 
extends Control

@onready var line : Line2D = $Outline/Line2D
@onready var outline : Line2D = $Outline
@onready var collision_shape : CollisionPolygon2D = $Area2D/CollisionShape

var collision_rect : Rect2

var undefined_color = Color.RED
var off_color = Color("545151")
var on_color = Color("241ec9")
var hover_color = Color.CORNFLOWER_BLUE
var side_offset = 5

var start_connection : Connection = null
var end_connection : Connection = null
var is_hovered := false


func _ready():
	Goventure.CursorCollision.register(self)

func update_loose_point(position) -> bool:
	if start_connection == null:
		set_start_point(position)
	elif end_connection == null:
		set_end_point(position)
	else:
		return false
	return true


func set_point(node):
	set_start_point(node.global_position) if node is Output else set_end_point(node.global_position)


func adjust_color(value):
	if value:
		self_modulate = on_color
	elif value == null:
		self_modulate = off_color
	else:
		self_modulate = undefined_color


func set_start_point(point : Vector2):
	line.points[0] = point
	outline.points[0] = point
	
	calc_collision(outline.points[0], outline.points[-1])


func get_start_point():
	return line.points[0]


func set_end_point(point : Vector2):
	line.points[-1] = point
	outline.points[-1] = point
	calc_collision(outline.points[-2], outline.points[-1])


func calc_collision(start, end):
	collision_shape.polygon[0] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg_to_rad(-90)).normalized() * outline.width / 2
	collision_shape.polygon[1] = start + start.direction_to(end) * side_offset + \
		start.direction_to(end).rotated(deg_to_rad(90)).normalized() * outline.width / 2
	collision_shape.polygon[2] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg_to_rad(90)).normalized() * outline.width / 2
	collision_shape.polygon[3] = end + end.direction_to(start) * side_offset + \
		start.direction_to(end).rotated(deg_to_rad(-90)).normalized() * outline.width / 2


func is_point_inside(point) -> bool:
	return Geometry2D.is_point_in_polygon(point, collision_shape.polygon)


func connect_to(connection):
	if connection == null:
		return
	if end_connection == null:
		end_connection = connection
		set_end_point(end_connection.get_attachment_point())
		end_connection.position_changed.connect(_on_end_position_changed)
	else:
		start_connection = connection
		set_start_point(start_connection.get_attachment_point())
		start_connection.position_changed.connect(_on_start_position_changed)


func _on_end_position_changed(new_pos):
	set_end_point(new_pos)


func _on_start_position_changed(new_pos):
	set_start_point(new_pos)


func get_end_point():
	return line.points[1]


@warning_ignore("native_method_override")
func set_z_index(new_index):
	outline.z_index = new_index


@warning_ignore("native_method_override")
func get_z_index():
	return outline.z_index


func _on_mouse_entered():
	outline.default_color = hover_color
	is_hovered = true


func _on_mouse_exited():
	outline.default_color = Color.BLACK
	is_hovered = false


func _input(event):
	if not is_hovered:
		return
	if Input.is_action_just_pressed("destroy"):
		destroy()


func destroy():
	if start_connection != null:
		start_connection.remove_cable(self)
		start_connection.unlink(end_connection)
	if end_connection == null:
		return
	end_connection.remove_cable(self)
	end_connection.unlink(start_connection)
	queue_free()


func _exit_tree():
	Goventure.CursorCollision.unregister(self)


func restore_configs(configs: Dictionary, cable_service: CableService):
	var start_connection = cable_service.get_connection_by_id(configs["start_connection_id"])
	var end_connection = cable_service.get_connection_by_id(configs["end_connection_id"])
	
	if start_connection == null:
		queue_free()
		return
	connect_to(start_connection)
	start_connection.connected_cables.append(self)
	
	if end_connection == null:
		queue_free()
		return
	connect_to(end_connection)
	end_connection.connected_cables.append(self)


func serialize() -> Dictionary:
	return {
		"path": scene_file_path, 
		"configs": {
			"start_connection_id": start_connection.id if start_connection != null else -1,
			"end_connection_id": end_connection.id if end_connection != null else -1
		}
	}
