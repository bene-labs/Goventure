@tool
extends VBoxContainer

@export var interactible_edit_scene : PackedScene


func _ready():
	if not Goventure.is_node_ready():
		await Goventure.ready
	for i in range(Goventure.interactibles.size()):
		var new_interactible_edit = interactible_edit_scene.instantiate()
		new_interactible_edit.setup(Goventure.interactibles[i], i != 0)
		add_child(new_interactible_edit)
	move_child($AddButtonContainer, -1)


func _on_add_action_button_pressed():
	add_child(interactible_edit_scene.instantiate())
	move_child($AddButtonContainer, -1)
