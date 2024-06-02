@tool
extends HBoxContainer

var interactable_name = ""


func setup(name, deletable = true):
	interactable_name = name
	$NameEdit.text = name
	if not deletable:
		$DeleteButton.hide()


func _on_name_edit_text_submitted(new_text):
	$NameEdit.modulate = Color.WHITE
	if new_text == interactable_name:
		return
	for interactable in Goventure.interactables:
		if new_text == interactable:
			$NameEdit.modulate = Color.RED
			return
	var prev_index = Goventure.interactables.find(interactable_name)
	interactable_name = new_text
	if prev_index >= 0:
		Goventure.interactables[prev_index] = new_text
	else:
		Goventure.interactables.push_back(new_text)
	Goventure._save()


func _on_name_edit_text_changed(new_text):
	_on_name_edit_text_submitted(new_text)


func _on_delete_button_pressed():
	Goventure.interactables.erase(interactable_name)
	Goventure._save()
	queue_free()

