@tool
extends VBoxContainer

@export var action_edit_scene : PackedScene


func _ready():
	if not Goventure.is_node_ready():
		await Goventure.ready
	for action in Goventure.actions:
		var new_action_edit = action_edit_scene.instantiate()
		new_action_edit.setup(action.title, action.combination_type)
		print("Added action: '%s'" % action.title)
		add_child(new_action_edit)
	move_child($ActionButtonContainer, -1)


func _on_add_action_button_pressed():
	add_child(action_edit_scene.instantiate())
	move_child($ActionButtonContainer, -1)
