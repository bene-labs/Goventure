extends Button

signal vs_node_spawned(vs_node)

@export var vs_node_prefab : PackedScene

func _ready():
	button_down.connect(_on_button_down)

func _on_button_down():
	var ctrans = get_canvas_transform()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	
	var min_pos = -ctrans.get_origin() / ctrans.get_scale()
	var max_pos = min_pos + view_size
	
	var new_vs_node = vs_node_prefab.instantiate()
	new_vs_node.global_position = get_global_mouse_position()
#	new_vs_node.global_position = Vector2(rand_range(min_pos.x + view_size.x * 0.2, max_pos.x - view_size.x * 0.01),
#		 rand_range(min_pos.y + view_size.y * 0.01, max_pos.y - + view_size.y * 0.01))
	get_parent().get_parent().get_parent().add_child(new_vs_node)
	new_vs_node.emit_signal("clicked", new_vs_node, Vector2.ZERO)
	
