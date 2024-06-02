extends Button

signal spwan_vs_node(vs_node_scene)

@export var vs_node_scene : PackedScene

@onready var vs_nodes = $"../../.."

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	var ctrans = get_canvas_transform()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	var new_vs_node = vs_nodes.spawn_vs_node(vs_node_scene)
	new_vs_node.global_position = get_global_mouse_position()
	new_vs_node.emit_signal("clicked", new_vs_node, Vector2.ZERO)
