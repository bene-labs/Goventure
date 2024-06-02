extends TextEdit


func _process(delta):
	if Input.is_action_just_pressed("test"):
		insert_text_at_caret("test")
	
	if not has_selection():
		return
	
	if Input.is_action_just_pressed("make_bold"):
		print("Selection mode %s" % str(get_selection_mode()))
		print('Selected text "%s" from %d-%d to %d-%d' % [
			get_selected_text(), get_selection_from_line(), get_selection_from_column(),
			get_selection_line(), get_selection_column()
		])
		
		toggle_tag(get_selection_from_line(), get_selection_from_column(), \
			get_selection_line(), get_selection_column(), "b")


func is_previous(pos1 : Vector2i, pos2 : Vector2i):
	return (pos1.x < pos2.x and pos1.y <= pos2.y) or pos1.y < pos2.y


func toggle_tag(from_line, from_column, to_line, to_column, tag):
	if from_line < 0 or from_column < 0 or to_line < 0 or to_column < 0:
		return
	
	deselect()
	
	var open_tag = "[" + tag + "]"
	var close_tag = "[\\" + tag + "]"
	
	var prev_open_pos = search(open_tag, SEARCH_MATCH_CASE, 0, 0)
	var prev_close_pos = search(close_tag, SEARCH_MATCH_CASE, 0, 0)
	
	if (prev_open_pos.x == -1 and prev_open_pos.y == -1) or \
		!is_previous(prev_open_pos, Vector2i(from_column, from_line)) or \
		is_previous(prev_open_pos, prev_close_pos):
			insert_tag(from_line, from_column, to_line, to_column, tag)
	
	select(from_line, from_column + open_tag.length(), to_line, to_column  + open_tag.length())
	

func insert_tag(from_line, from_column, to_line, to_column, tag):
	var open_tag = "[" + tag + "]"
	var close_tag = "[\\" + tag + "]"

	insert_text_at_caret(close_tag, add_caret(to_line, to_column))
	remove_secondary_carets()
	insert_text_at_caret(open_tag, add_caret(from_line, from_column))
	remove_secondary_carets()


func _on_gutter_added():
	print(get_gutter_count())
	
	for i in range(get_gutter_count()):
		print("Gutter %d -> name: '%s', type: %s, width: %d." %
		 [get_gutter_name(i), str(get_gutter_type(i)), get_gutter_width(i)])
