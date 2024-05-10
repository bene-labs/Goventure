class_name InputConnection extends Connection

signal destroyed(input)

@export var accepted_connection_types : Array[ConnectionType]

@onready var cables = get_tree().get_nodes_in_group("Cables")[0]

var connected_output = null
var connected_input = null
var connected_cable = null
var extra_cable = null


func _ready():
	super._ready()
	clicked.connect(_on_Input_clicked)
	released_over.connect(_on_Input_released_over)

func set_value(value):
	super.set_value(value)
	if weakref(extra_cable).get_ref():
		extra_cable.adjust_color(value)
	if  weakref(connected_input).get_ref() and connected_input.connected_cable == extra_cable:
		connected_input.set_value(value)

func link_chained_input(input, cable):
	if connected_cable != null:
		connected_cable.queue_free()
	if extra_cable != null:
		extra_cable.queue_free()
	connected_input = input
	extra_cable = cable
	set_value(TriState.State.UNDEFINED)

func link(connection, cable):
	if connected_cable != null:
		connected_cable.queue_free()
		connected_cable = null
	if !is_standalone and extra_cable != null:
		extra_cable.queue_free()
	connected_output = connection
	connected_cable = cable
	#print("connected '", connection.get_path(), "' with '", get_path(), "' => value: ", connection.value.value)
	set_value(connection.value)


func can_connect(other: Connection) -> bool:
	if not other is Output:
		return false
	for accepted_type in accepted_connection_types:
		if other.connection_types & (1 << accepted_type):
			return true
	return false


func _on_Input_clicked(node):
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()
		connected_cable = null
		connected_output = null
		set_value(TriState.State.UNDEFINED)

func _on_Input_released_over(node):
	if weakref(connected_cable).get_ref():
		return
	if connected_cable != null:
		connected_cable.queue_free()
		connected_cable = null
		connected_output = null

func _on_z_index_changed(new_index):
	super._on_z_index_changed(new_index)
#	if weakref(connected_cable).get_ref():
#		connected_cable.set_z_index(new_index - 1)
	set_z_index(new_index)

func _on_destroy():
	if weakref(connected_cable).get_ref():
		connected_cable.queue_free()

func _exit_tree():
	super._exit_tree()
	emit_signal("destroyed", self)
