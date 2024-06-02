class_name Output extends Connection


func _ready():
	super._ready()
	inactive_color = Color("eac07d")
	active_color = Color("cd8715")
	interactionSprite.self_modulate = inactive_color


func set_value(value):
	super.set_value(value)
	for cable in connected_cables:
		cable.adjust_color(value)
	for input in linked_connections:
		input.set_value(value)


func can_connect(other: Connection):
	if not super.can_connect(other):
		return false
	if other is Output:
		return false
	if parent_node in other.get_all_connections() \
		.filter(func (x): return not x.is_standalone and x is InputConnection) \
		.map(func (x): return x.parent_node):
		return false
	return true

func link(connection : Connection, cable: Cable = null):
	if parent_node is InteractableBaseNode and connection.connection_types & (1 << ConnectionType.ACTION) == 0 or \
		connection.get_all_connections().filter( \
		func(x): return x is InputConnection and x.connection_types & (1 << ConnectionType.ACTION) == 0).size() > 0:
		for linked_connection in linked_connections:
			if linked_connection.connection_types & (1 << ConnectionType.ACTION) == 0 or \
				linked_connection.get_all_connections().filter( \
				func(x): return x is InputConnection and x.connection_types & (1 << ConnectionType.ACTION) == 0).size() > 0:
				unlink(linked_connection)
	super.link(connection, cable)
