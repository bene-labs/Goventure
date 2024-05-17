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
