extends Node

signal command_executed(command: CommandData)

enum CommandModes {
	EMIT_SIGNALS,
	RUN_IN_DIALOGIC
}

var resource_dir = "res://addons/goventure/resources/interaction_data/"
var command_mode := CommandModes.RUN_IN_DIALOGIC

var configs = Configs.new()

var actions : Array[Action] = [
	Action.new("use", Action.CombinationType.OPTIONAL),
	Action.new("combine", Action.CombinationType.MANDTORY),
	Action.new("examine", Action.CombinationType.NONE)]
var interactibles : Array[String] = ["Red Key", "Blue Lock", "Red Lock", "Door", "Coin"]

var queued_commands := []


func run_action(action: String, interactible1: String, interactible2 := ""):
	match command_mode:
		CommandModes.EMIT_SIGNALS:
			queue_action_commands(action, interactible1, interactible2)
		CommandModes.RUN_IN_DIALOGIC:
			run_action_in_dialogic(action, interactible1, interactible2)


func queue_action_commands(action: String, interactible1: String, interactible2 := "", overwrite_queue = false):
	var path = resource_dir + "/" + interactible1 + ".tres"
	if not ResourceLoader.exists(path):
		return
	var interactionData : InteractionData = load(path)
	
	if overwrite_queue:
		queued_commands.clear()
	queued_commands += interactionData.get_commands_by_action(action, interactible2)


func is_command_queued() -> bool:
	return queued_commands.size() > 0


func advance_queued_commands() -> bool:
	if not is_command_queued():
		return false
	command_executed.emit(queued_commands.pop_front())
	return true


func get_random_command_path(random_paths: Array):
	randomize()
	var total_weight = 0
	for random_path : CommandPathData in random_paths:
		total_weight += random_path.value
	
	var hit = randi_range(1, total_weight)
	var weight_index = total_weight
	for random_path : CommandPathData in random_paths:
		weight_index -= random_path.value
		if hit > weight_index:
			return random_path.path
	push_error("Inventory Error: failed to pick random command path.")


func get_sequence_command_path(sequence_command: BranchingCommandData):
	if not sequence_command.value is int:
		sequence_command.value = int(sequence_command.value)
	if sequence_command.value >= sequence_command.paths.size():
		match sequence_command.type:
			"LoopSequence":
				sequence_command.value = 0
			"RepeatLastSequence":
				sequence_command.value = sequence_command.paths.size() - 1
			"StopSequence":
				return []
	var active_path = sequence_command.paths[sequence_command.value].path
	sequence_command.value += 1
	return active_path


func run_action_in_dialogic(action: String, interactible1: String, interactible2 := ""):
	if get_tree() == null or not get_tree().root.has_node("Dialogic"):
		push_error("Dialogic Autoload not found. Ensure the plugin is propely installed.")
		return
	
	var events : Array
	var path = resource_dir + "/" + interactible1 + ".tres"
	if not ResourceLoader.exists(path):
		return
	var interactionData : InteractionData = load(path)

	var commands = interactionData.get_commands_by_action(action, interactible2)
	var remaining_commands = commands.size()
	var i = 0
	while (i < remaining_commands):
		var command = commands[i]
		match command.type:
			"say":
				events.append(command.value)
			"Random":
				commands = get_random_command_path(command.paths)
				i = -1
				remaining_commands = commands.size()
			"LoopSequence", "RepeatLastSequence", "StopSequence":
				commands = get_sequence_command_path(command)
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

class Action:
	enum CombinationType {
		NONE,
		MANDTORY,
		OPTIONAL
	}
	
	var title := ""
	var combination_type : CombinationType
	
	func _init(title, combination_type):
		self.title = title
		self.combination_type = combination_type
