class_name Interactible
extends Node


@export var id := ""
@export var interactions := "open in Editor"


func do_action(action: String, with : Interactible = null):
	if with != null:
		Goventure.run_action(action, id, with.id)
	else:
		Goventure.run_action(action, id)
