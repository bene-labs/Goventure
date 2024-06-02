extends Control

var scene_name = "default_scene"


func _ready():
	if not Goventure.is_node_ready():
		await Goventure.ready
	_load()


func _load():
	var path = "%s/%s.save" %[Goventure.save_dir_path, scene_name]
	if not FileAccess.file_exists(path):
		return
	
	var save_data = FileAccess.open(path, FileAccess.READ).get_var(true)
	if save_data == null:
		return
	if "camera_configs" in save_data:
		$Camera.restore_configs(save_data["camera_configs"])
	%Cables.connection_id = 1000
	await $VSNodes.load_nodes(save_data["nodes"])
	if "connections" in save_data:
		await %Cables.load_connections(save_data["connections"])
	if "cables" in save_data:
		await %Cables.load_cables(save_data["cables"])


func _save():
	var path = "%s/%s.save" %[Goventure.save_dir_path, scene_name]
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var save_dict = $VSNodes.serialize()
	save_dict.merge(%Cables.serialize())
	save_dict.merge($Camera.serialize())
	file.store_var(save_dict, true)
	file.close()


func _input(event):
	if event.is_action_pressed("save"):
		_save()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
