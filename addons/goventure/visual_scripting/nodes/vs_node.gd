class_name VSNode
extends Control

signal clicked(VSNode, offset)
signal released(VSNode)
signal position_changed
signal z_index_changed(new_index)
signal destroy
signal destroyed(VSNode)

var hover_color = Color.LIGHT_BLUE

var default_color

@onready var vs_nodes : VSNodes = get_parent()
@onready var collision_shape = $Area2D/CollisionPolygon2D
@onready var image = $Sprite


var is_hovered = false
var is_dragged = false
var drag_mode_queded = false

var sprite_z_index = z_index

var title := "Node"
var param = "None"


func _ready():
	Goventure.CursorCollision.register(self)
	default_color = image.modulate

	for output in %Outputs.get_children():
		output.is_standalone = false
		output.parent_node = self
		position_changed.connect(output._on_position_changed)
		z_index_changed.connect(output._on_z_index_changed)
	if get_node_or_null("%Inputs") != null:
		for input in %Inputs.get_children():
			input.is_standalone = false
			input.parent_node = self
			input.value_changed.connect(_on_input_changed)
			position_changed.connect(input._on_position_changed)
			z_index_changed.connect(input._on_z_index_changed)
		call_deferred("_on_input_changed")


func get_connections():
	return get_inputs() + get_outputs()


func get_outputs():
	return %Outputs.get_children()


func get_inputs():
	return %Inputs.get_children() if get_node_or_null("%Inputs") != null else []


func _on_input_changed():
	pass


func _on_mouse_entered():
	image.modulate = hover_color
	is_hovered = true


func _on_mouse_exited():
	if drag_mode_queded:
		clicked.emit(self, global_position - get_global_mouse_position())
		drag_mode_queded = false
	image.modulate = default_color
	is_hovered = false


func set_dragged():
	is_dragged = true
	Goventure.CursorCollision.lock()


func set_undragged():
	is_dragged = false
	Goventure.CursorCollision.unlock()


func _input(event):
	if is_dragged and Input.is_action_just_released("vs_node"):
		emit_signal("released", self)
	
	if not is_hovered:
		return

	if Input.is_action_just_pressed("destroy") and not is_dragged:
		Goventure.CursorCollision.unregister(self)
		emit_signal("destroy")
		call_deferred("queue_free")
	elif Input.is_action_just_pressed("vs_node") and not drag_mode_queded:
		drag_mode_queded = true
		await get_tree().create_timer(0.1).timeout
		try_start_drag_mode()
	
	if Input.is_action_just_pressed("rotate_vs_node"):
		rotate_counterclockwise()


func try_start_drag_mode():
	if not drag_mode_queded:
		return true
	drag_mode_queded = false
	if not is_hovered or not Input.is_action_pressed("vs_node"):
		return false
	
	clicked.emit(self, global_position - get_global_mouse_position())
	return true


func update_position(value):
	position = value
	emit_signal("position_changed")


@warning_ignore("native_method_override")
func set_z_index(value):
	z_index = value
	sprite_z_index = value
	emit_signal("z_index_changed", value)


@warning_ignore("native_method_override")
func get_z_index():
	return sprite_z_index


func rotate_counterclockwise():
	$Sprite.rotate(deg_to_rad(90.0))
	update_position(position)


func is_point_inside(point):
	return Geometry2D.is_point_in_polygon($Sprite.to_local(point), collision_shape.polygon)


func restore_configs(configs: Dictionary):
	global_position = configs["position"]
	rotation = configs["rotation"]
	
	var connections = get_connections()
	for i in range(configs["connection_configs"].size()):
		if i >= connections.size():
			return
		connections[i].restore_configs(configs["connection_configs"][i])


func serialize() -> Dictionary:
	return {
		"path": scene_file_path, 
		"configs": {
			"position": global_position,
			"rotation": rotation,
			"connection_configs": get_connections().map(func(x): return x.serialize()["configs"])
		}
	}


func _exit_tree():
	emit_signal("destroyed", self)
