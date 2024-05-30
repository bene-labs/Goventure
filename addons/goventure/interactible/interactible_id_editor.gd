extends EditorProperty


var property_control = OptionButton.new()
var current_value = "None"
var updating = false


func _init():
	for interactible in Goventure.interactibles:
		property_control.add_item(interactible)
	if property_control.item_count > 0:
		current_value = property_control.get_item_text(0)
		
	refresh_control_text()
	add_child(property_control)
	add_focusable(property_control)
	property_control.item_selected.connect(_on_id_selected)


func _on_id_selected(index):
	if (updating):
		return

	current_value = property_control.get_item_text(index)
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)


func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false


func refresh_control_text():
	property_control.text = current_value
