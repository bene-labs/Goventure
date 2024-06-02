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


func put_vs_node_in_front(vs_node):
	vs_nodes.erase(vs_node)
	vs_nodes.push_front(vs_node)
	apply_vs_node_z_index()
	Goventure.CursorCollision.update_order()


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


func spawn_vs_node(vs_node_scene: PackedScene):
	var new_vs_node = vs_node_scene.instantiate()
	add_child(new_vs_node)
	vs_nodes.append(new_vs_node)
	new_vs_node.clicked.connect(_on_vs_node_clicked)
	new_vs_node.released.connect(_on_vs_node_released)
	new_vs_node.destroyed.connect(_on_vs_node_destroyed)
	for connection in new_vs_node.get_connections():
		cables.register_connection(connection)
	return new_vs_node

func _on_connection_added(new_connection):
	cables.register_connection(new_connection)


func get_nodes():
	return get_children().filter(func(x): return x is VSNode)


func load_nodes(nodes_data: Array):
	for node in vs_nodes:
		node.queue_free()
	vs_nodes.clear()
	for node_data in nodes_data:
		spawn_vs_node(load(node_data["path"]))
	await get_tree().process_frame
	for i in range(get_nodes().size()):
		await get_nodes()[i].restore_configs(nodes_data[i]["configs"])


func serialize():
	var nodes = []
	for node in get_nodes():
		nodes.push_back(node.serialize())
	return {"nodes": nodes}
