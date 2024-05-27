class_name CableService
extends Control

signal active_cable_value_changed(is_active)

var cable_scene = preload("res://addons/goventure/visual_scripting/Cable.tscn")
var cable_connection_scene = preload("res://addons/goventure/visual_scripting/connections/CableConnection.tscn")

var active_cable : Cable = null
var active_start_connection = null

var connection_id = 0

var connections : Array[Connection]

var is_input_required = false
var tween : Tween


func _input(event):
	if active_cable != null and Input.is_action_just_released("cable"):
		call_deferred("add_cable_connection")


func _process(delta):
	if active_cable != null:
		active_cable.update_loose_point(get_global_mouse_position())


func get_connection_by_id(id):
	if id < 0:
		return null
	for connection : Connection in connections:
		if connection.id == id:
			return connection
	return null


func register_connection(new_connection):
	connections.append(new_connection)
	new_connection.id = connection_id
	new_connection.clicked.connect(_on_connection_clicked)
	new_connection.released_over.connect(_on_connection_released)
	new_connection.destroyed.connect(remove_connection)
	connection_id += 1


func remove_connection(to_remove):
	connections.erase(to_remove)


func _on_connection_clicked(connection):
	is_input_required = connection is Output
	show_available_connections(connection)
	create_new_cable(connection)


func show_available_connections(from : Connection):
	for connection in connections:
		if connection.can_connect(from):
			connection.set_active()
			CursorCollision.add_to_whitelist(connection)


func hide_available_connections():
	for connection in connections:
		connection.set_inactive()
	active_cable_value_changed.emit(false)
	CursorCollision.clear_whitelist()

func create_new_cable(start_node):
	if active_cable != null:
		active_cable.destroy()
		active_cable = null
	active_cable = cable_scene.instantiate()
	add_child(active_cable)
	active_cable.connect_to(start_node)
	#active_cable.outline.z_index = start_node.z_index - 1
	active_start_connection = start_node
	active_cable_value_changed.emit(true)
	# CursorCollision.add_to_whitelist(input_script_path if is_input_required else output_script_path)


func _on_connection_released(over):
	link_active_cable(over)


func link_active_cable(end_point):
	active_cable.connect_to(end_point)
	active_start_connection.link(end_point, active_cable)
	end_point.link(active_start_connection, active_cable)
	active_cable = null
	hide_available_connections()


func add_cable_connection():
	if active_cable == null:
		return
	for connection in connections:
		if connection.is_point_inside(get_global_mouse_position()):
			remove_active_cable()
			return
	var mouse_pos = get_global_mouse_position()
	var new_start_point = cable_connection_scene.instantiate()
	
	new_start_point.global_position = mouse_pos
	new_start_point.copy(active_start_connection)
	get_tree().root.add_child(new_start_point)
	active_start_connection.link(new_start_point, active_cable)
	new_start_point.link(active_start_connection, active_cable)
	active_cable.connect_to(new_start_point)
	register_connection(new_start_point)
	
	CursorCollision.put_in_front(new_start_point)
	active_cable = null
	hide_available_connections()


func remove_active_cable():
	if active_cable == null:
		return
	active_cable.destroy()
	active_cable = null
	active_start_connection = null
	hide_available_connections()


func is_cable_active():
	return active_cable != null


func load_connections(connections_data: Array):
	for connection_data in connections_data:
		var new_connection = load(connection_data["path"]).instantiate()
		get_tree().current_scene.add_child(new_connection)
		register_connection(new_connection)
		new_connection.restore_configs(connection_data["configs"])
		
	for connection in connections:
		for linked_connection_id in connection.linked_connection_ids:
			connection.link(get_connection_by_id(linked_connection_id))
	connection_id = connections.map(func(x): return x.id).max() + 1


func load_cables(cables_data: Array):
	for cable_data in cables_data:
		var new_cable = load(cable_data["path"]).instantiate()
		add_child(new_cable)
		if not new_cable.is_node_ready():
			await new_cable.ready
		new_cable.restore_configs(cable_data["configs"], self)


func serialize():
	return {
		"connections": connections
			.filter(func(x): return x.is_standalone)
			.map(func(x): return x.serialize()),
		"cables": get_children().map(func(x): return x.serialize())
	}
