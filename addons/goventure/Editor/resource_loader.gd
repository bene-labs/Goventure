@tool
extends VBoxContainer

signal resource_selected(path: String)

@export_dir var resource_folder_path


func _ready():

	update_resource_list()

func update_resource_list():
	%ResourcesList.clear()
	for file_name in DirAccess.open(resource_folder_path).get_files():
		%ResourcesList.add_item(file_name)


func _on_resources_list_item_activated(index):
	var selected_item = %ResourcesList.get_item_text(index)
	
	%CurrentResource.text = selected_item
	resource_selected.emit(resource_folder_path + "/" + selected_item)
