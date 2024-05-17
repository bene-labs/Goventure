extends VSNode

@export_dir var interaction_data_path = "res://addons/goventure/resources/"
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
		new_label.text = action.title
		new_output.name = action.title
		match action.combination_type:
			action.CombinationType.OPTIONAL:
				new_output.connection_types = 1 << Connection.ConnectionType.ACTION
				new_output.connection_types += 1 << Connection.ConnectionType.FLOW
			action.CombinationType.MANDTORY:
				new_output.connection_types = 1 << Connection.ConnectionType.ACTION
				new_output.incompatible_connection_types = 1 << Connection.ConnectionType.FLOW
			action.CombinationType.NONE:
				new_output.connection_types = 1 << Connection.ConnectionType.FLOW
				new_output.incompatible_connection_types = 1 << Connection.ConnectionType.ACTION
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


func _input(event):
	if event.is_action_pressed("save"):
		save_to_file()
	super._input(event)


func add_action_text_rec(start_node: VSNode, text := "") -> String:
	for output : Output in start_node.outputs:
		for node : VSNode in output.get_connected_input_nodes():
			text += "\t" + node.title + " " + node.param + "\n"
			text += add_action_text_rec(node)
	return text



func save_to_file():
	var file := FileAccess.open(save_directory + "/" + title + ".gv", FileAccess.WRITE)
	var text := ""
	
	for output : Output in outputs:
		for node : VSNode in output.get_connected_input_nodes():
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
	save_to_resource(text)

func save_to_resource(text: String):
	var interaction_data = InteractionData.new()
	var lines = text.split("\n")
	var i = 0
	while i < lines.size():
		var key : String
		if lines[i] == "":
			break
		if lines[i].contains("with"):
			key = lines[i].split(" with")[0]
			key += lines[i].split(" with")[1]
			key = key.trim_suffix(":")
		else:
			key = lines[i].trim_suffix(":")
		interaction_data.command_lookup[key] = []
		i += 1
		while i < lines.size() and lines[i].contains("\t"):
			#match lines[i].split(" ")[0]:
				#"say":
			var command = CommandData.new()
			command.value = lines[i].split('\"')[1]
			interaction_data.command_lookup[key].append(command)
			i += 1
	ResourceSaver.save(interaction_data, interaction_data_path + "interaction_data/" + title + ".tres")


func _on_interactible_selection_item_selected(index):
	title = %InteractibleSelection.get_item_text(index)

