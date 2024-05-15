class_name CommandData
extends Resource

enum CommandType {
	DIALOGUE
}
@export var type := CommandType.DIALOGUE
@export var value = ""

func _init(type, value):
	self.type = type
	self.value = value
