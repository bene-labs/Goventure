class_name CableConnection extends Connection

var started_from_input = false

func _ready():
	super._ready()
	is_standalone = true
	inactive_color = Color.WHITE_SMOKE
	active_color = Color.DARK_GRAY
	interactionSprite.self_modulate = inactive_color


func can_connect(other: Connection):
	if not other.is_multiple_connection_allowed and get_connected_input_nodes().size() > 1:
		return false
	return super.can_connect(other)


func _on_connections_changed():
	var lowest_types : ConnectionType
	var all_incompatible_types : ConnectionType = 0
	var is_multiple_connection_always_allowed = true
	
	for type in ConnectionType.values():
		lowest_types |= 1 << type
	
	
	for connection in get_all_connections().filter(func(x): return not x.is_standalone and x is Output):
		lowest_types = lowest_types & connection.connection_types
		all_incompatible_types = all_incompatible_types | connection.incompatible_connection_types
		if not connection.is_multiple_connection_allowed:
			is_multiple_connection_always_allowed = false
	connection_types = lowest_types
	incompatible_connection_types = all_incompatible_types
	is_multiple_connection_allowed = is_multiple_connection_always_allowed
	for connection in get_all_connections().filter(func(x): return x.is_standalone):
		connection.connection_types = connection_types
		connection.incompatible_connection_types = incompatible_connection_types
		connection.is_multiple_connection_allowed = is_multiple_connection_always_allowed


func unlink_connected_input_nodes():
	for connection: Connection in get_all_connections().filter(func(x): return not x.is_standalone and x is InputConnection):
		for linked_connection in connection.linked_connections:
			if not linked_connection == self and not self in linked_connection.get_all_connections():
				continue
			connection.unlink(linked_connection)
			break


func link(connection : Connection, cable: Cable = null):
	if not is_multiple_connection_allowed and get_connected_input_nodes().size() != 0:
		if not connection.is_standalone and connection is InputConnection or \
			connection.is_standalone and connection.get_connected_input_nodes().size() != 0:
			unlink_connected_input_nodes()
	super.link(connection, cable)
	if cable == null:
		return
	call_deferred("_on_connections_changed")

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
