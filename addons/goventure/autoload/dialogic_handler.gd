extends Node


func run_action_in_dialogic(action: String, interactable1: String, interactable2 := ""):
	if get_tree() == null or not get_tree().root.has_node("Dialogic"):
		push_error("Dialogic Autoload not found. Ensure the plugin is propely installed.")
		return
	
	var events : Array
	var path = Goventure.resource_dir_path + "/" + interactable1 + ".tres"
	if not ResourceLoader.exists(path):
		return
	var interactionData : InteractionData = load(path)

	var commands = interactionData.get_commands_by_action(action, interactable2)
	var remaining_commands = commands.size()
	var i = 0
	while (i < remaining_commands):
		var command = commands[i]
		match command.type:
			"say":
				events.append(command.value)
			"Random":
				commands = Goventure.get_random_command_path(command.paths)
				i = -1
				remaining_commands = commands.size()
			"LoopSequence", "RepeatLastSequence", "StopSequence":
				commands = Goventure.get_sequence_command_path(command)
				i = -1
				remaining_commands = commands.size()
			_:
				push_error("Unkown command '%'", command.type)
		i += 1
	if events.size() == 0:
		return

	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	Dialogic.start(timeline)
	ResourceSaver.save(interactionData, path)
