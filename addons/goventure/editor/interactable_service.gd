@tool
extends VBoxContainer

@export var interactable_edit_scene : PackedScene


func _ready():
	if not Goventure.is_node_ready():
		await Goventure.ready
	for i in range(Goventure.interactables.size()):
		var new_interactable_edit = interactable_edit_scene.instantiate()
		new_interactable_edit.setup(Goventure.interactables[i], i != 0)
		add_child(new_interactable_edit)
	move_child($AddButtonContainer, -1)


func _on_add_action_button_pressed():
	add_child(interactable_edit_scene.instantiate())
	move_child($AddButtonContainer, -1)
