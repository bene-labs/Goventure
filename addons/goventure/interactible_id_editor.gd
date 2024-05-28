extends EditorProperty


# The main control for editing the property.
var property_control = OptionButton.new()
# An internal value of the property.
var current_value = "None"
# A guard against internal changes when the property is updated.
var updating = false


func _init():
	for interactible in Goventure.interactibles:
		property_control.add_item(interactible)
	if property_control.item_count > 0:
		current_value = property_control.get_item_text(0)
	# Add the control as a direct child of EditorProperty node.
	add_child(property_control)
	# Make sure the control is able to retain the focus.
	add_focusable(property_control)
	# Setup the initial state and connect to the signal to track changes.
	refresh_control_text()
	property_control.item_selected.connect(_on_id_selected)


func _on_id_selected(index):
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return

	current_value = property_control.get_item_text(index)
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)


func _update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	refresh_control_text()
	updating = false

func refresh_control_text():
	property_control.text = current_value
