class_name BranchingCommandData
extends CommandData

@export var paths := []

static func create_from_command_data(data: CommandData):
	var new_data = BranchingCommandData.new()
	new_data.value = data.value
	new_data.type = data.type
	return new_data
