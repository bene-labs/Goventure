@tool
extends Node

signal command_executed(command: CommandData)

enum CommandModes {
	EMIT_SIGNALS,
	RUN_IN_DIALOGIC
}

var CursorCollision = preload("res://addons/goventure/visual_scripting/cursor_collision.gd").new()

var resource_dir_path = "res://addons/goventure/resources/interaction_data/"
var save_dir_path = "res://addons/goventure/resources"
var command_mode := CommandModes.RUN_IN_DIALOGIC
var dialogic_handler = null

var actions := [Action.new("default action", Action.CombinationType.OPTIONAL)]
var interactables := ["default interactable"]

var queued_commands := []


func _ready():
	add_child(CursorCollision)
	if get_tree() != null and get_tree().root.has_node("Dialogic"):
		dialogic_handler = load("res://addons/goventure/autoload/dialogic_handler.gd").new()
		add_child(dialogic_handler)
	var usr_args = OS.get_cmdline_user_args()
	for usr_arg in usr_args:
		print("usr_arg received: %s" % usr_arg)
		if usr_arg.begins_with("save_path="):
			var potential_save_dir = usr_arg.split("=")[1]
			if not FileAccess.file_exists(potential_save_dir):
				push_error("Invalid Save Path Arg: %s. Directory does not exit." % potential_save_dir)
				break
			save_dir_path = potential_save_dir
		elif usr_arg.begins_with("resource_path="):
			var potential_resource_dir = usr_arg.split("=")[1]
			if not FileAccess.file_exists(potential_resource_dir):
				push_error("Invalid Resource Path Arg: %s. Directory does not exit." % potential_resource_dir)
				break
			resource_dir_path = potential_resource_dir
	_load()


func _save():
	var path = "%s/configs.save" % save_dir_path
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_var({
		"actions_titles": actions.map(func(x): return x.title),
		"actions_types": actions.map(func(x): return x.combination_type),
		"interactables": interactables
	}, true)


func _load():
	var path = "%s/configs.save" % save_dir_path
	if not FileAccess.file_exists(path):
		return
	
	var save_file = FileAccess.open(path, FileAccess.READ)
	var save_dict = save_file.get_var(true)
	if save_dict == null:
		return
	interactables.clear()
	actions.clear()
	interactables = save_dict["interactables"]
	for i in range(save_dict["actions_titles"].size()):
		actions.push_back(Action.new(save_dict["actions_titles"][i], save_dict["actions_types"][i]))


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST \
		or what == NOTIFICATION_EDITOR_PRE_SAVE \
		or what == NOTIFICATION_UNPARENTED:
		_save()


func run_action(action: String, interactable1: String, interactable2 := ""):
	match command_mode:
		CommandModes.EMIT_SIGNALS:
			queue_action_commands(action, interactable1, interactable2)
		CommandModes.RUN_IN_DIALOGIC:
			if dialogic_handler == null:
				push_error("Cannot run action with Dialogic: Dialogic Autoload not found. Ensure the plugin is propely installed.")
				return
			dialogic_handler.run_action_in_dialogic(action, interactable1, interactable2)


func queue_action_commands(action: String, interactable1: String, interactable2 := "", overwrite_queue = false):
	var path = resource_dir_path + "/" + interactable1 + ".tres"
	if not ResourceLoader.exists(path):
		return
	var interactionData : InteractionData = load(path)
	
	if overwrite_queue:
		queued_commands.clear()
	queued_commands += interactionData.get_commands_by_action(action, interactable2)


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


func _exit_tree():
	if GoventureInteractionsEditorProperty.interaction_editor_pid >= 0:
		OS.kill(GoventureInteractionsEditorProperty.interaction_editor_pid)
		GoventureInteractionsEditorProperty.interaction_editor_pid = -1

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
