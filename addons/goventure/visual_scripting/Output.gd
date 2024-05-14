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
	for type in ConnectionType.values():
		type = 1 << type
		if connection_types & type == 0:
			continue
		if connection_types & type == other.connection_types & type:
			return true
	return false
