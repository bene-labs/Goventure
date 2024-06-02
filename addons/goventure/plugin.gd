@tool
extends EditorPlugin


const MainPanel = preload("res://addons/goventure/editor/editor_main.tscn")
const PLUGIN_NAME := "Goventure"
const PLUGIN_HANDLER_PATH := "res://addons/goventure/autoload/goventure.gd"

var main_panel_instance


func _init() -> void:
	self.name = "GoventurePlugin"


func _enable_plugin():
	add_autoload_singleton(PLUGIN_NAME, PLUGIN_HANDLER_PATH)


func _disable_plugin():
	remove_autoload_singleton(PLUGIN_NAME)


func _enter_tree():
	add_inspector_plugin(preload("res://addons/goventure/interactable/interactable_inspector_plugin.gd").new())
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return PLUGIN_NAME


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("CharacterBody2D", "EditorIcons")
