@tool
extends CodeEdit

var current_file : FileAccess


func _input(event):
	if event.is_action_pressed("save"):
		save_current_file()

func save_current_file():
	if current_file == null:
		return
	current_file.store_string(text)


func open_new_file(path: String) -> bool:
	if !FileAccess.file_exists(path):
		return false
	save_current_file()
	current_file = FileAccess.open(path, FileAccess.READ_WRITE)
	text = current_file.get_as_text()
	return true


func _exit_tree():
	save_current_file()
