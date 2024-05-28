@tool
extends HBoxContainer

var interactible_name = ""


func setup(name):
	interactible_name = name
	$NameEdit.text = name


func _on_name_edit_text_submitted(new_text):
	$NameEdit.modulate = Color.WHITE
	if new_text == interactible_name:
		return
	for interactible in Goventure.interactibles:
		if new_text == interactible:
			$NameEdit.modulate = Color.RED
			return
	var prev_index = Goventure.interactibles.find(interactible_name)
	interactible_name = new_text
	if prev_index >= 0:
		Goventure.interactibles[prev_index] = new_text
	else:
		Goventure.interactibles.push_back(new_text)
	Goventure._save()


func _on_name_edit_text_changed(new_text):
	_on_name_edit_text_submitted(new_text)


func _on_delete_button_pressed():
	Goventure.interactibles.erase(interactible_name)
	Goventure._save()
	queue_free()

