class_name Output extends Connection

signal destroyed(output)


@export_flags("Action", "Flow") var connection_types : int

var connected_inputs = []
var connected_cables : Array = []

func _ready():
	super._ready()
	inactive_color = Color("eac07d")
	active_color = Color("cd8715")
	interactionSprite.self_modulate = inactive_color
	set_value(TriState.State.TRUE)

func set_value(value):
	super.set_value(value)
	for cable in connected_cables:
		cable.adjust_color(value)
	for input in connected_inputs:
		input.set_value(value)

func link(connection, cable):
	connected_inputs.append(connection)
	connected_cables.append(cable)
	for connected_cable in connected_cables:
		connected_cable.adjust_color(value)

func delete_all_cables():
	for cable in connected_cables:
		cable.queue_free()
	connected_cables.clear()

func remove_cable(cable):
	var idx_to_remove = connected_cables.find(cable)
	if idx_to_remove < 0:
		return
	
	connected_cables.remove_at(idx_to_remove)
	if connected_inputs[idx_to_remove] != null and "connected_output" in connected_inputs[idx_to_remove]:
		connected_inputs[idx_to_remove].connected_output = null
	connected_inputs.remove_at(idx_to_remove)

func can_connect(other: Connection):
	if not other is InputConnection:
		return false
	for accepted_type in other.accepted_connection_types:
		if connection_types & (1 << accepted_type):
			return true
	return false

func _on_z_index_changed(new_index):
	super._on_z_index_changed(new_index)
	set_z_index(new_index)


func _on_destroy():
	for connected_cable in connected_cables:
		if weakref(connected_cable).get_ref():
			connected_cable.queue_free()


func get_connected_nodes():
	var connected_nodes : Array
	
	for input in connected_inputs:
		while input.is_standalone and input.connected_input != null:
			input = input.connected_input
		if not input.is_standalone:
			connected_nodes.push_back(input.parent_node)
	return connected_nodes


func _exit_tree():
	super._exit_tree()
	emit_signal("destroyed", self)
