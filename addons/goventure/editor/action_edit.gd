@tool
extends HBoxContainer

var selected_type_idx = 0
var action_name = ""

func _ready():
	$ActionTypeSelections.clear()
	for type in Goventure.Action.CombinationType.keys():
		$ActionTypeSelections.add_item(type)
	$ActionTypeSelections.selected = selected_type_idx


func setup(name, selected_type_idx):
	action_name = name
	$NameEdit.text = name
	self.selected_type_idx = selected_type_idx


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_name_edit_text_submitted(new_text):
	action_name = new_text
	var matching_actions = Goventure.actions.filter(func(x): return x.title == action_name)
	if matching_actions.size() == 1:
		matching_actions[0].title = new_text
	elif matching_actions.size() == 0:
		Goventure.actions.push_back(Goventure.Action.new(action_name, selected_type_idx))
	Goventure._save()


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
