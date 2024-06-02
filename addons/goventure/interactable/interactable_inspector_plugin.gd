extends EditorInspectorPlugin


var InteractableIdEditor = preload("res://addons/goventure/interactable/interactable_id_editor.gd")
var InteractionsEditor = preload("res://addons/goventure/interactable/interactable_interactions_editor.gd")


func _can_handle(object):
	# We support all objects in this example.
	return object is Interactable


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if not object is Interactable:
		return false
	
	match name:
		"id":
			add_property_editor(name, InteractableIdEditor.new())
			return true
		"interactions":
			add_property_editor(name, InteractionsEditor.new())
			return true
		_:
			return false
