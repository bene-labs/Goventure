extends Control

signal active_cable_value_changed(is_active)

var cable_scene = preload("res://addons/goventure/visual_scripting/Cable.tscn")
var cable_connection_scene = preload("res://addons/goventure/visual_scripting/connections/CableConnection.tscn")

var active_cable : Cable = null
var active_start_connection = null

@onready var inputs = get_tree().get_nodes_in_group("Input")
@onready var outputs = get_tree().get_nodes_in_group("Output")

var is_input_required = false
var tween : Tween


func _ready():
	for input in inputs:
		input.clicked.connect(_on_connection_clicked)
		input.released_over.connect(_on_connection_released)
		input.destroyed.connect(remove_input)
	for output in outputs:
		output.clicked.connect(_on_connection_clicked)
		output.released_over.connect(_on_connection_released)
		output.destroyed.connect(remove_output)
	
	emit_signal("active_cable_value_changed", false)

func _input(event):
	if active_cable != null and Input.is_action_just_released("cable"):
		call_deferred("add_cable_connection")
	
func _process(delta):
	if active_cable != null:
		active_cable.update_loose_point(get_global_mouse_position())


func register_input(input):
	inputs.append(input)
	input.clicked.connect(_on_connection_clicked)
	input.released_over.connect(_on_connection_released)
	input.destroyed.connect(remove_input)

func register_output(output):
	outputs.append(output)
	output.clicked.connect(_on_connection_clicked)
	output.released_over.connect(_on_connection_released)
	output.destroyed.connect(remove_output)


func remove_input(input):
	inputs.erase(input)


func remove_output(output):
	outputs.erase(output)


func _on_connection_clicked(connection):
	is_input_required = connection is Output
	show_available_connections(connection)
	create_new_cable(connection)


func show_available_connections(from : Connection):
	for input in inputs:
		if input.can_connect(from):
			input.set_active()
			CursorCollision.add_to_whitelist(input)
	for output in outputs:
		if output.can_connect(from):
			output.set_active()
			CursorCollision.add_to_whitelist(output)


func hide_available_connections():
	for input in inputs:
		input.set_inactive()
	for output in outputs:
		output.set_inactive()
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
	for input in inputs:
		if input.is_point_inside(get_global_mouse_position()):
			remove_active_cable()
			return
	for output in outputs:
		if output.is_point_inside(get_global_mouse_position()):
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
	if is_input_required:
		register_input(new_start_point)
	else:
		register_output(new_start_point)
	#if is_input_required:
		#new_start_point.name = "Output"
		#register_output(new_start_point)
		#active_cable.connect_input(new_start_point)
		#active_start_connection.link(new_start_point, active_cable)
		#new_start_point.value = active_start_connection.value
	#else:
		#new_start_point.name = "Input"
		#register_input(new_start_point)
		#active_cable.connect_output(new_start_point)
		#new_start_point.link_chained_input(active_start_connection, active_cable)
		#active_start_connection.link(new_start_point, active_cable)
	
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
