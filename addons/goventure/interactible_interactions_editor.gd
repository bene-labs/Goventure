extends EditorProperty


# The main control for editing the property.
var property_control = Button.new()
# An internal value of the property.
var current_value = ""
# A guard against internal changes when the property is updated.
var updating = false


func _init():
	property_control.text = current_value
	add_child(property_control)
	add_focusable(property_control)
	refresh_control_text()
	property_control.pressed.connect(_on_edit_button_pressed)


func _on_edit_button_pressed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return
	if current_value == "open in Editor":
		current_value = "close Editor"
	else:
		current_value = "open in Editor"
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
