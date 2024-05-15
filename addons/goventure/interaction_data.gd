class_name InteractionData
extends Resource

@export var command_lookup : Dictionary


func get_commands_by_action(action: String, with = ""):
	var key = action + with
	if command_lookup.has(key):
		return []
	return command_lookup[key]



