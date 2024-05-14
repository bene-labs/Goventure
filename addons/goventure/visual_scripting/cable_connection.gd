class_name CableConnection extends Connection


func _ready():
	super._ready()
	is_standalone = true
	inactive_color = Color.WHITE_SMOKE
	active_color = Color.DARK_GRAY


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
