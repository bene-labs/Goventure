@tool
extends HBoxContainer

var selected_type_idx = 0
var action_name = ""

func _ready():
	$ActionTypeSelections.clear()
	for type in Goventure.Action.CombinationType.keys():
		$ActionTypeSelections.add_item(type)
	$ActionTypeSelections.selected = selected_type_idx


func setup(name, selected_type_idx, deletable = true):
	action_name = name
	$NameEdit.text = name
	self.selected_type_idx = selected_type_idx
	if not deletable:
		$DeleteButton.disabled = true


func _on_name_edit_text_submitted(new_text):
	$NameEdit.modulate = Color.WHITE
	if new_text == action_name:
		return
	for action in Goventure.actions:
		if new_text == action.title:
			$NameEdit.modulate = Color.RED
			return
	var matching_actions = Goventure.actions.filter(func(x): return x.title == action_name)
	action_name = new_text
	if matching_actions.size() == 1:
		matching_actions[0].title = new_text
	elif matching_actions.size() == 0:
		Goventure.actions.push_back(Goventure.Action.new(action_name, selected_type_idx))
	Goventure._save()


func _on_name_edit_text_changed(new_text):
	_on_name_edit_text_submitted(new_text)


func _on_action_type_selections_item_selected(index):
	selected_type_idx = index
	var matching_actions = Goventure.actions.filter(func(x): return x.title == action_name)
	if matching_actions.size() == 1:
		matching_actions[0].combination_type = selected_type_idx
	Goventure._save()


func _on_delete_button_pressed():
	var matching_actions = Goventure.actions.filter(func(x): return x.title == action_name)
	for action in matching_actions:
		Goventure.actions.erase(action)
	Goventure._save()
	queue_free()
