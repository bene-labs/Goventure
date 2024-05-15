@tool
extends CodeEdit


var current_file : FileAccess


func _enter_tree():
	var code_highlighting = CodeHighlighter.new()
	code_highlighting.add_keyword_color("with", Color.CORAL)
	code_highlighting.add_keyword_color("say", Color.PALE_VIOLET_RED)
	code_highlighting.add_color_region('\"', '\"', Color.BISQUE)
	code_highlighting.symbol_color = Color.WHITE
	code_highlighting.member_variable_color = Color.WHITE
	code_highlighting.number_color = Color.WHITE
	code_highlighting.function_color = Color.WHITE
	syntax_highlighter = code_highlighting
	
	#for action in Goventure.actions:
		#code_highlighting.add_keyword_color(action, Color.SKY_BLUE)
	#for interactible in Goventure.interactibles:
		#code_highlighting.add_keyword_color(interactible, Color.SKY_BLUE)
		
	


func _notification(what):
	if what == NOTIFICATION_EDITOR_PRE_SAVE:
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
