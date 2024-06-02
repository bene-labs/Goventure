@tool
extends Control


func _on_resource_loader_resource_selected(path):
	%GoventureCodeEditor.open_new_file(path)


func _on_editor_tab_bar_tab_selected(tab):
	for i in range(%Editors.get_child_count()):
		if i == tab:
			%Editors.get_child(i).show()
		else:
			%Editors.get_child(i).hide()
