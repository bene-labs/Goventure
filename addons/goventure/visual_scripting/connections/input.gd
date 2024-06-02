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
	return true
