class_name CableConnection extends Connection


func _ready():
	is_standalone = true
	interactionSprite.self_modulate = Color.WHITE_SMOKE
	super._ready()


func set_value(value):
	super.set_value(value)
	for cable in connected_cables:
		cable.adjust_color(value)
	for input in linked_connections:
		input.set_value(value)

func link(connection, cable):
	if not is_multiple_connections:
		clear_cables()
		connected_cables.clear()
		linked_connections.clear()
	linked_connections.append(connection)
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
	if linked_connections[idx_to_remove] != null and "connected_output" in linked_connections[idx_to_remove]:
		linked_connections[idx_to_remove].connected_output = null
	linked_connections.remove_at(idx_to_remove)

func can_connect(other: Connection):
	if not super.can_connect(other):
		return false
	for type in ConnectionType.values():
		type = 1 << type
		if connection_types & type == 0:
			continue
		if connection_types & type == other.connection_types & type:
			return true
	return false

func _on_z_index_changed(new_index):
	super._on_z_index_changed(new_index)
	set_z_index(new_index)


func _on_destroy():
	for connected_cable in connected_cables:
		if weakref(connected_cable).get_ref():
			connected_cable.queue_free()


func add_connected_nodes_rec(connection : Connection, connected_nodes: Array, searched_nodes = []):
	if connection in searched_nodes:
		return
	searched_nodes.append(connection)
	if connection.is_standalone:
		for linked_connection in connection.linked_connections:
			add_connected_nodes_rec(linked_connection, connected_nodes, searched_nodes)
		return
	if connection is Output:
		return
	if connection in connected_nodes:
		return
	connected_nodes.append(connection.parent_node)


func get_connected_nodes():
	var connected_nodes : Array
	
	for connection in linked_connections:
		if not connection.is_standalone:
			connected_nodes.push_back(connection.parent_node)
			continue
		add_connected_nodes_rec(connection, connected_nodes)
	return connected_nodes
