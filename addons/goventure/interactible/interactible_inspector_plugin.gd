extends EditorInspectorPlugin


var InteractibleIdEditor = preload("res://addons/goventure/interactible/interactible_id_editor.gd")
var InteractionsEditor = preload("res://addons/goventure/interactible/interactible_interactions_editor.gd")


func _can_handle(object):
	# We support all objects in this example.
	return object is Interactible


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if not object is Interactible:
		return false
	
	match name:
		"id":
			add_property_editor(name, InteractibleIdEditor.new())
			return true
		"interactions":
			add_property_editor(name, InteractionsEditor.new())
			return true
		_:
			return false
