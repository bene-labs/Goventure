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
	for type in ConnectionType.values():
		type = 1 << type
		if connection_types & type == 0:
			continue
		if connection_types & type == other.connection_types & type:
			return true
	return false
