class_name Connection extends Control

signal value_changed
signal clicked(connection: Connection)
signal released_over(connection: Connection)
signal position_changed(new_pos)
signal destroyed(connection)

enum ConnectionType {
	ACTION,
	FLOW
}


@export_flags("Action", "Flow") var connection_types : int
@export_flags("Action", "Flow") var incompatible_connection_types : int
@export var is_multiple_connection_allowed := true
@export var undefined_color = Color.RED
@export var off_color = Color("545151")
@export var on_color = Color("241ec9")
@export var inactive_color = Color("b1e2f1")
@export var active_color = Color("65c2dd")

@onready var wire = get_node_or_null("InteractionPoint/Wire")
@onready var interactionSprite : TextureRect = %InteractionPoint
@onready var base_scale = interactionSprite.scale

var collision_radius = 26.0


var parent_node : VSNode = null
var linked_connections = []
var connected_cables : Array = []

var is_hovered : bool = false
var is_active : bool = false
var is_standalone = true

var value = null
var is_dragged = false
var drag_offset = Vector2.ZERO
var is_mouse_movement = false

func _ready():
	self_modulate = off_color
	interactionSprite.self_modulate = inactive_color
	CursorCollision.register(self)
	clicked.connect(_on_clicked)
	released_over.connect(_on_released_over)


func copy(other: Connection):
	connection_types = other.connection_types
	incompatible_connection_types = other.incompatible_connection_types
	is_multiple_connection_allowed = other.is_multiple_connection_allowed
	value = other.value


func set_value(value):
	self.value = value
	self_modulate = on_color
	$DelayTimer.wait_time = Goventure.configs.simulation_speed
	$DelayTimer.start()
	await $DelayTimer.timeout
	value_changed.emit()


func link(connection : Connection, cable: Cable):
	if connection in linked_connections:
		return
	linked_connections.append(connection)
	if cable == null:
		return
	if not is_multiple_connection_allowed and not is_standalone:
		clear_cables()
	connected_cables.append(cable)
	for connected_cable in connected_cables:
		connected_cable.adjust_color(value)
	if is_standalone and not is_multiple_connection_allowed:
		_on_new_cable(connection)


func unlink(from: Connection):
	if from == null:
		return
	from.linked_connections.erase(self)
	linked_connections.erase(from)
	if is_standalone and get_connected_nodes().size() == 0:
		queue_free()


func get_attachment_point():
	return %AttachmentPoint.global_position


func can_connect(other : Connection):
	if parent_node != null and parent_node == other.parent_node:
		return false
	if other in get_all_connections():
		return false
	for type in ConnectionType.values():
		type = 1 << type
		if incompatible_connection_types & type and other.connection_types & type:
			return false
		if other.incompatible_connection_types & type and connection_types & type:
			return false
	for type in ConnectionType.values():
		type = 1 << type
		if connection_types & type == 0:
			continue
		if connection_types & type == other.connection_types & type:
			return true
	return false

#region mouse interaction
func _on_mouse_entered():
	interactionSprite.scale = base_scale * 1.25
	is_hovered = true


func _on_mouse_exited():
	interactionSprite.scale = base_scale
	is_hovered = false


func set_active():
	is_active = true
	interactionSprite.self_modulate = active_color


func set_inactive():
	is_active = false
	interactionSprite.self_modulate = inactive_color


func is_point_inside(point):
	return get_attachment_point().distance_to(point) <= collision_radius

#endregion


#region get connected
func add_all_connections_rec(connection : Connection, connected_nodes: Array, \
	searched_nodes := []):
	if connection in searched_nodes:
		return
	searched_nodes.append(connection)
	if connection.is_standalone:
		for linked_connection in connection.linked_connections:
			add_all_connections_rec(linked_connection, connected_nodes, searched_nodes)
	if connection in connected_nodes:
		return
	connected_nodes.append(connection)


func get_all_connections():
	var all_connections : Array
	
	for connection in linked_connections:
		if not connection.is_standalone:
			all_connections.push_back(connection)
			continue
		add_all_connections_rec(connection, all_connections)
	return all_connections


func get_connected_nodes():
	return get_all_connections() \
		.filter(func(x): return x.parent_node != null) \
		.map(func(x): return x.parent_node)


func get_connected_input_nodes():
	return get_all_connections() \
		.filter(func(x): return x.parent_node != null and x is InputConnection) \
		.map(func(x): return x.parent_node)


func get_connected_output_nodes():
	return get_all_connections() \
		.filter(func(x): return x.parent_node != null and x is Output) \
		.map(func(x): return x.parent_node)

#endregion

func _input(event):
	if not is_hovered:
		return
	
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false
	
	if Input.is_action_just_pressed("cable"):
		clicked.emit(self)
	elif is_active and Input.is_action_just_released("cable"):
		released_over.emit(self)
	elif is_standalone and Input.is_action_just_pressed("drag_connection"):
		is_dragged = true
		drag_offset = global_position - get_global_mouse_position()
		CursorCollision.lock()
	elif is_dragged and Input.is_action_just_released("drag_connection"):
		is_dragged = false
		CursorCollision.unlock()

func _process(delta):
	if !is_dragged or !is_mouse_movement:
		return
	set_position(get_global_mouse_position() + drag_offset)
	_on_position_changed()


func _on_z_index_changed(new_index):
	set_z_index(new_index)


func remove_cable(to_remove: Cable):
	connected_cables.erase(to_remove)


func clear_cables():
	for cable in connected_cables.duplicate():
		cable.destroy()
	connected_cables.clear()


@warning_ignore("native_method_override")
func set_z_index(value, wire_offset = 0):
	z_index = value
	if wire == null:
		return
	wire.z_index = wire_offset


func _on_clicked(node):
	if not is_multiple_connection_allowed and not is_standalone:
		clear_cables()


func _on_new_cable(to_connection):
	var connected_input_nodes = get_connected_input_nodes()
	if connected_input_nodes.size() > 1:
		for input_node in connected_input_nodes:
			var inputs = input_node.get_inputs()
			if to_connection in inputs:
				continue
			inputs[0].clear_cables()


func _on_released_over(node):
	if not is_multiple_connection_allowed and not is_standalone:
		clear_cables()


func _on_position_changed():
	position_changed.emit(get_attachment_point())


func restore_configs(configs: Dictionary):
	pass


func serialize() -> Dictionary:
	return {
		"path": scene_file_path
	}

func _exit_tree():
	clear_cables()
	for linked_connection in linked_connections:
		linked_connection.unlink(self)
	CursorCollision.unregister(self)
	destroyed.emit(self)
