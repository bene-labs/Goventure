extends Control

@export_dir var save_dir = "res://addons/goventure/resources/vs_scenes/"


func _ready():
	var save_data = FileAccess.open("user://default_scene.save", FileAccess.READ).get_var(true)
	$VSNodes.load_nodes(save_data["nodes"])


func _save():
	var file = FileAccess.open("user://default_scene.save", FileAccess.WRITE)
	file.store_var($VSNodes.serialize(), true)
	file.close()


func _input(event):
	if event.is_action_pressed("save"):
		_save()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save()
