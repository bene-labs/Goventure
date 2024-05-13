extends VSNode

@export var output_node : PackedScene
@export var output_label : PackedScene
@export_dir var save_directory 

func _ready():
	%InteractibleSelection.clear()
	for interactible in Goventure.interactibles:
		%InteractibleSelection.add_item(interactible)
	%InteractibleSelection.selected = 0
	title = %InteractibleSelection.get_item_text(%InteractibleSelection.selected)

	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	for action in Goventure.actions:
		var new_label := output_label.instantiate()
		var new_output := output_node.instantiate()
		new_label.text = action
		new_output.name = action
		%OutputLabels.add_child(new_label)
		%Outputs.add_child(new_output)
		%Outline.size.y += 50
		%ColorRect.size.y += 50
		colision_polygon[2].y += 50
		colision_polygon[3].y += 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	
	super._ready()
	for output in outputs:
		output.set_value(TriState.State.FALSE)


func add_action_text_rec(start_node: VSNode, text := "") -> String:
	for output : Output in start_node.outputs:
		for node : VSNode in output.get_connected_nodes():
			text += "\t" + node.title + " " + node.param + "\n"
			text += add_action_text_rec(node)
	return text


func _input(event):
	if event.is_action_pressed("save"):
		save_to_file()
	super._input(event)


func save_to_file():
	var file := FileAccess.open(save_directory + "/" + title + ".txt", FileAccess.WRITE)
	var text := ""
	
	for output : Output in outputs:
		for node : VSNode in output.get_connected_nodes():
			text += output.name
			if node is ActionCombinationNode:
				text += " "
			else:
				text += ":\n\t"
			text += node.title + ' '
			text += node.param
			if node is ActionCombinationNode:
				text += ":\n"
			else:
				text += "\n"
			text += add_action_text_rec(node)
	file.store_string(text)


func _on_interactible_selection_item_selected(index):
	title = %InteractibleSelection.get_item_text(index)

