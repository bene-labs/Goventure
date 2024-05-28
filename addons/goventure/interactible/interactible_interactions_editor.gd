extends EditorProperty

var interaction_editor_exe_path = ProjectSettings.globalize_path("res://addons/goventure/exe_test/Gunkey_Prototype.exe")
static var interaction_editor_pid = -1
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
	if (updating):
		return
	if current_value == "open in Editor":
		interaction_editor_pid = OS.create_process(interaction_editor_exe_path, [])
		current_value = "close Editor"
	else:
		_try_to_kill_interaction_editor()
		current_value = "open in Editor"
	refresh_control_text()
	emit_changed(get_edited_property(), current_value)


func _try_to_kill_interaction_editor():
	if interaction_editor_pid >= 0:
		OS.kill(interaction_editor_pid)


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

func _exit_tree():
	_try_to_kill_interaction_editor()
