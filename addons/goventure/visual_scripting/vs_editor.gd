extends Control

@export_dir var save_dir = "res://addons/goventure/resources/vs_scenes/"


func _ready():
	_load()


func _load(path = "user://default_scene.save"):
	if not FileAccess.file_exists(path):
		return
	
	var save_data = FileAccess.open(path, FileAccess.READ).get_var(true)
	if save_data == null:
		return
	await $VSNodes.load_nodes(save_data["nodes"])
	if "connections" in save_data:
		await %Cables.load_connections(save_data["connections"])
	if "cables" in save_data:
		await %Cables.load_cables(save_data["cables"])


func _save():
	var file = FileAccess.open("user://default_scene.save", FileAccess.WRITE)
	
	var save_dict = $VSNodes.serialize()
	save_dict.merge(%Cables.serialize())
	
	file.store_var(save_dict, true)
	file.close()


func _input(event):
	if event.is_action_pressed("save"):
		_save()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
