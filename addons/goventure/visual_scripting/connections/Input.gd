class_name InputConnection extends Connection

var connected_input = null


func _ready():
	super._ready()
	
	self_modulate = undefined_color


func can_connect(other: Connection) -> bool:
	if not super.can_connect(other):
		return false
	if other is InputConnection:
		return false
	if parent_node in other.get_all_connections() \
		.filter(func (x): return not x.is_standalone and x is Output) \
		.map(func (x): return x.parent_node):
		return false
	for type in ConnectionType.values():
		type = 1 << type
		if incompatible_connection_types & type and other.connection_types & type:
			return false
		if other.incompatible_connection_types & type and connection_types & type:
			return false
	if other.is_standalone:
		for output in other.get_all_connections(). \
			filter(func(x): return x is Output and x.parent_node is InteractableBaseNode):
			if output.connection_types & (1 << ConnectionType.ACTION) == 0 and output.get_all_connections() \
			.filter(func(x): return x is InputConnection and x.connection_types & (1 << ConnectionType.ACTION) == 0).size() > 0:
				return false
	else:
		if other.parent_node is InteractableBaseNode and \
			connection_types & (1 << ConnectionType.ACTION) == 0 and other.get_all_connections() \
			.filter(func(x): return x is InputConnection and x.connection_types & (1 << ConnectionType.ACTION) == 0).size() > 0:
			return false
	return true
