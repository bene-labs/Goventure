extends VSNode

@export var output_node : PackedScene
@export var output_label : PackedScene


func _ready():
	%InteractableSelection.clear()
	for interactable in Goventure.interactables:
		%InteractableSelection.add_item(interactable)
	%InteractableSelection.selected = 0
	title = %InteractableSelection.get_item_text(%InteractableSelection.selected)

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


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()


func _input(event):
	if event.is_action_pressed("save"):
		save()
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
	ResourceSaver.save(interaction_data, "%s/%s.tres" % [Goventure.resource_dir_path, title])


func _on_interactable_selection_item_selected(index):
	title = %InteractableSelection.get_item_text(index)


func restore_configs(configs: Dictionary):
	super.restore_configs(configs)
	if configs["selected"] < %InteractableSelection.item_count:
		%InteractableSelection.selected = configs["selected"]
	title = %InteractableSelection.get_item_text(%InteractableSelection.selected)


func serialize() -> Dictionary:
	var serial_data = super.serialize()
	serial_data["configs"]["selected"] = %InteractableSelection.selected
	return serial_data
