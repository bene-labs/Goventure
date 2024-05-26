class_name VSNodes
extends Control

signal drag_toggled(new_state)

@export var cables : Control
@onready var button_rect = %ColorRect

var buttons = []
var vs_nodes : Array

var dragged_vs_node = null
var drag_offset = Vector2.ZERO
var is_mouse_movement = false


func _ready():
	#for vs_node in vs_nodes:
		#vs_node.clicked.connect(_on_vs_node_clicked)
		#vs_node.released.connect(_on_vs_node_released)
		#vs_node.destroyed.connect(_on_vs_node_destroyed)
	#call_deferred("apply_vs_node_z_index")
	for button in button_rect.get_children():
		buttons.append(button)
		button.vs_node_spawned.connect(_on_vs_node_spawned)


func put_vs_node_in_front(vs_node):
	vs_nodes.erase(vs_node)
	vs_nodes.push_front(vs_node)
	apply_vs_node_z_index()
	CursorCollision.update_order()


func apply_vs_node_z_index():
	var z_index = vs_nodes.size() * 3
	for vs_node in vs_nodes:
		vs_node.set_z_index(z_index)
		z_index -= 3


func _on_vs_node_clicked(vs_node, offset: Vector2):
	put_vs_node_in_front(vs_node)
	dragged_vs_node = vs_node
	drag_offset = offset
	vs_node.set_dragged()
	emit_signal("drag_toggled", true)


func _on_vs_node_released(vs_node):
	vs_node.set_undragged()
	dragged_vs_node = null
	emit_signal("drag_toggled", false)


func _on_vs_node_destroyed(vs_node):
	vs_nodes.erase(vs_node)


func _process(delta):
	if dragged_vs_node == null or not is_mouse_movement:
		return
	dragged_vs_node.update_position(dragged_vs_node.get_global_mouse_position() + drag_offset)


func _input(event):
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false


func _on_vs_node_spawned(new_vs_node):
	vs_nodes.append(new_vs_node)
	new_vs_node.clicked.connect(_on_vs_node_clicked)
	new_vs_node.released.connect(_on_vs_node_released)
	new_vs_node.destroyed.connect(_on_vs_node_destroyed)
	for input in new_vs_node.get_inputs():
		cables.register_input(input)
	for output in new_vs_node.get_outputs():
		cables.register_output(output)


func _on_output_added(new_output):
	cables.register_output(new_output)


func _on_input_added(new_input):
	cables.register_output(new_input)


func load_nodes(nodes_data: Array):
	for node in vs_nodes:
		node.queue_free()
	vs_nodes.clear()
	for node_data in nodes_data:
		var new_node = load(node_data["path"]).instantiate()
		add_child(new_node)
	await get_tree().process_frame
	for i in range(vs_nodes.size()):
		vs_nodes[i].restore_configs(nodes_data[i]["configs"])


func serialize():
	var nodes = []
	for node in vs_nodes:
		nodes.push_back(node.serialize())
	return {"nodes": nodes}
