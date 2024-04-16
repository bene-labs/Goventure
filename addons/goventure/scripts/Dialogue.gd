extends Node

enum RunModes {
	RunViaDialogic,
	ExposeSignals
}

@export var run_mode := RunModes.RunViaDialogic
@export var paths : Array[GoventureDialoguePath]


func _ready():
	
	match run_mode:
		RunModes.RunViaDialogic:
			_run_as_timeline()
		_:
			pass

func _run_as_timeline():
	var events : Array

	for path : GoventureDialoguePath in paths:
		var path_uid_str = str(path.resource_path)
		events.push_back("set Goventure.path_rid = '%s'" % path_uid_str)
		for i in path.path.size():
			var qa : GoventureDialogueQA =  path.path[i]
			events.push_back('- %s [if %s == %d][else="hide"]' % 
				[qa.question, "Goventure.depth", i])
			events.push_back("\t%s" % qa.answer)
			if (path.is_looping and i == path.path.size() - 1):
				events.push_back("\tset Goventure.depth = 0")
			else:
				events.push_back("\tset Goventure.depth += 1")
			events.push_back("\tjump")

	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	Dialogic.start(timeline)

#@export var generate_dialogic_timeline : bool:
	#set(value):
		#print("test")
		##on_generate_dialogic_timeline()

#func on_generate_dialogic_timeline():
	#var file_dialog = EditorFileDialog.new()
	#file_dialog.file_mode = 0
	#file_dialog.add_filter("*.csv")
	#file_dialog.title = "Choose a cards table to import."
	#EditorInterface.get_editor_main_screen().add_child(file_dialog)
	#file_dialog.popup_centered(Vector2i(420, 360))
	#file_dialog.show()
	#file_dialog.file_selected.connect(save_as_timeline)
	#
#
#func save_as_timeline(file_path : String):
	#var file = FileAccess.open(file_path, FileAccess.WRITE)
	#var timeline_str := ""
	#
	#for path in paths:
		#var qa : DialogueQA
		#timeline_str += "- %s\n" % qa.question
		#timeline_str += "\t%s\n" % qa.answer
	#file.store_string(timeline_str)
