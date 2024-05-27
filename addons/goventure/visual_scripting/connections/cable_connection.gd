class_name CableConnection extends Connection


func _ready():
	super._ready()
	is_standalone = true
	inactive_color = Color.WHITE_SMOKE
	active_color = Color.DARK_GRAY
	interactionSprite.self_modulate = inactive_color

func can_connect(other: Connection):
	if other is InputConnection:
		for output in get_all_connections() \
			.filter(func(x): return not x.is_standalone and x is Output):
			if not output.can_connect(other):
				return false
	elif other is Output:
		for input in get_all_connections() \
			.filter(func(x): return not x.is_standalone and x is InputConnection):
			if not input.can_connect(other):
				return false
	else:
		for connection in get_all_connections() \
			.filter(func(x): return not x.is_standalone):
			if not other.can_connect(connection):
				return false
	
	for type in ConnectionType.values():
		type = 1 << type
		if connection_types & type == 0:
			continue
		if connection_types & type == other.connection_types & type:
			return true
	return false


func _on_connections_changed():
	var lowest_types : ConnectionType
	var all_incompatible_types : ConnectionType = 0
	var input_nodes = get_connected_input_nodes()
	var connected_input_node_count = get_connected_input_nodes().size()
	
	for type in ConnectionType.values():
		lowest_types |= 1 << type
	
	
	for conection in get_all_connections().filter(func(x): return not x.is_standalone and x is Output):
		if connected_input_node_count > 1 and not conection.is_multiple_connection_allowed:
			conection.clear_cables()
			continue
		lowest_types = lowest_types & conection.connection_types
		all_incompatible_types = all_incompatible_types | conection.incompatible_connection_types
	connection_types = lowest_types
	incompatible_connection_types = all_incompatible_types
	for connection in get_all_connections().filter(func(x): return x.is_standalone):
		connection.connection_types = connection_types
		connection.incompatible_connection_types = incompatible_connection_types


func link(connection : Connection, cable: Cable = null):
	super.link(connection, cable)
	if cable == null:
		return
	_on_connections_changed()


func unlink(from: Connection):
	super.unlink(from)
	_on_connections_changed()


func restore_configs(configs: Dictionary):
	super.restore_configs(configs)
	global_position = configs["position"]


func serialize() -> Dictionary:
	var serial_dict = super.serialize()
	serial_dict["configs"]["position"] = global_position
	return serial_dict
