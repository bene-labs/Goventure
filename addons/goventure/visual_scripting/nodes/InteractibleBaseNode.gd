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
		new_label.text = action.title
		new_output.name = action.title
		new_output.value = action.title
		match action.combination_type:
			action.CombinationType.OPTIONAL:
				new_output.connection_types = 1 << Connection.ConnectionType.ACTION
				new_output.connection_types += 1 << Connection.ConnectionType.FLOW
			action.CombinationType.MANDTORY:
				new_output.connection_types = 1 << Connection.ConnectionType.ACTION
				new_output.incompatible_connection_types = 1 << Connection.ConnectionType.FLOW
			action.CombinationType.NONE:
				new_output.connection_types = 1 << Connection.ConnectionType.FLOW
				new_output.is_multiple_connection_allowed = false
		%OutputLabels.add_child(new_label)
		%Outputs.add_child(new_output)
		%Outline.size.y += 50
		%ColorRect.size.y += 50
		colision_polygon[2].y += 50
		colision_polygon[3].y += 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	
	super._ready()


func _input(event):
	if event.is_action_pressed("save"):
		save()
		#save_to_file()
	super._input(event)


func get_command_paths(outputs: Array) -> Array:
	var command_paths := []
	for output : Output in outputs:
		var new_path = CommandPathData.new()
		new_path.value = output.value
		new_path.path = get_commands(output)
		command_paths.push_back(new_path)
	return command_paths


func get_commands(output: Output) -> Array:
	var commands := []
	while output.get_connected_input_nodes().size() != 0:
		var node = output.get_connected_input_nodes()[0]
		var new_command = CommandData.new()
		var outputs = node.get_outputs().filter(func(x): return x != output)
		new_command.type = node.title
		new_command.value = node.param
		if outputs.size() == 1:
			output = outputs[0]
			commands.push_back(new_command)
		else:
			new_command = BranchingCommandData.create_from_command_data(new_command)
			new_command.paths = get_command_paths(outputs)
			commands.push_back(new_command)
			return commands
	return commands


func save():
	var interaction_data = InteractionData.new()
	
	for output : Output in %Outputs.get_children():
		for node : VSNode in output.get_connected_input_nodes():
			var key := ""
			var output_to_use = output
			key += output.name
			if node is ActionCombinationNode:
				key += " " + node.param
				output_to_use = node.get_outputs()[0]
			if key in interaction_data.command_lookup.keys():
				push_error("Error when saving '%s'. 
					Action Combination '%s' is already defined." % [title, key])
				continue
			interaction_data.command_lookup[key] = get_commands(output_to_use)
	ResourceSaver.save(interaction_data, Goventure.resource_dir_path + title + ".tres")


func add_action_text_rec(start_node: VSNode, text := "") -> String:
	for output : Output in start_node.get_outputs():
		for node : VSNode in output.get_connected_input_nodes():
			text += "\t" + node.title + " " + node.param + "\n"
			text += add_action_text_rec(node)
	return text


func save_to_file():
	var file := FileAccess.open(save_directory + "/" + title + ".gv", FileAccess.WRITE)
	var text := ""
	
	for output : Output in %Outputs.get_children():
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
			var command = CommandData.new()
			command.value = lines[i].split('\"')[1]
			interaction_data.command_lookup[key].append(command)
			i += 1
	ResourceSaver.save(interaction_data, Goventure.resource_dir_path + title + ".tres")


func _on_interactible_selection_item_selected(index):
	title = %InteractibleSelection.get_item_text(index)


func restore_configs(configs: Dictionary):
	super.restore_configs(configs)
	if configs["selected"] < %InteractibleSelection.item_count:
		%InteractibleSelection.selected = configs["selected"]
	title = %InteractibleSelection.get_item_text(%InteractibleSelection.selected)


func serialize() -> Dictionary:
	var serial_data = super.serialize()
	serial_data["configs"]["selected"] = %InteractibleSelection.selected
	return serial_data
