class_name InteractionData
extends Resource

@export var command_lookup : Dictionary


func get_commands_by_action(action: String, with = ""):
	var key = action
	if with != "":
		key += " " + with
	if not command_lookup.has(key):
		return []
	return command_lookup[key]



