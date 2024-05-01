@tool
extends RichTextLabel

func _input(event):
	if event.is_action_pressed("ui_text_completion_query") and get_selection_from() != -1:
		toggle_tag(get_selection_from(), get_selection_to(), "b")
		return
	
	if not event is InputEventKey or not event.is_pressed():
		return
	if event.is_action_pressed("ui_text_newline"):
		text += "\n"
	elif event.is_action_pressed("ui_text_backspace"):
		text = text.substr(0, text.length() - 1)
	else:
		#print(event.unicode)
		text += char(event.unicode)
		
	
		


func toggle_tag(from, to, tag):
	deselect()
	
	var open_tag = "[" + tag + "]"
	var close_tag = "[/" + tag + "]"
	var prev_open_idx = text.rfind(open_tag, to)
	var prev_close_idx = text.rfind(close_tag, from)
	
	if prev_open_idx != -1 and prev_open_idx > prev_close_idx:
		remove_tag(from, prev_open_idx, tag)
	else:
		insert_tag(from, to, tag)


func insert_tag(from, to, tag):
	var open_tag = "[" + tag + "]"
	var close_tag = "[/" + tag + "]"
	
	text = text.insert(from, open_tag)
	text = text.insert(to + 1 + open_tag.length(), close_tag)
	
func remove_tag(from, open_pos, tag):
	var open_tag = "[" + tag + "]"
	var close_tag = "[/" + tag + "]"
	
	text = text.erase(open_pos, open_tag.length())
	
	var next_open_idx = text.find(open_tag, from)
	var next_close_idx = text.find(close_tag, from)
	if next_close_idx != -1 and (next_open_idx == -1 or next_close_idx < next_open_idx):
		text = text.erase(next_close_idx, close_tag.length())
	
