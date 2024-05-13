class_name InputConnection extends Connection

@onready var cables = get_tree().get_nodes_in_group("Cables")[0]


var connected_input = null
var extra_cable = null


func _ready():
	super._ready()
	clicked.connect(_on_Input_clicked)
	released_over.connect(_on_Input_released_over)
	self_modulate = undefined_color

func set_value(value):
	super.set_value(value)
	if weakref(extra_cable).get_ref():
		extra_cable.adjust_color(value)
	if  weakref(connected_input).get_ref() and extra_cable in connected_input.connected_cables:
		connected_input.set_value(value)

func link_chained_input(input, cable):
	if not is_multiple_connections:
		connected_cables.clear()
	if extra_cable != null:
		extra_cable.queue_free()
	connected_input = input
	extra_cable = cable
	set_value(TriState.State.UNDEFINED)

func link(connection, cable):
	if not is_multiple_connections:
		clear_cables()
		connected_cables.clear()
	if !is_standalone and extra_cable != null:
		extra_cable.queue_free()
	if is_multiple_connections:
		linked_connections.append(connection)
		connected_cables.append(cable)
	else:
		linked_connections = [connection]
		connected_cables = [cable]
	#print("connected '", connection.get_path(), "' with '", get_path(), "' => value: ", connection.value.value)
	set_value(connection.value)


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


func _on_Input_clicked(node):
	if is_multiple_connections:
		return
	clear_cables()
	connected_cables.clear()
	linked_connections.clear()
	set_value(TriState.State.UNDEFINED)

func _on_Input_released_over(node):
	if is_multiple_connections:
		return
	clear_cables()
	connected_cables.clear()
	linked_connections.clear()

func _on_z_index_changed(new_index):
	super._on_z_index_changed(new_index)
#	if weakref(connected_cable).get_ref():
#		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	clear_cables()

