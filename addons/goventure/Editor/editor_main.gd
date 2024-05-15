@tool
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_resource_loader_resource_selected(path):
	%GoventureCodeEditor.open_new_file(path)
