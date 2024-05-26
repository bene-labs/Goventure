extends VSNode

@export var output_node_scene : PackedScene
@export var output_label_scene : PackedScene

var output_count = 0


func _ready():
	super._ready()
	title = "LoopSequence"
	param = "0"
	for i in range(%Outputs.get_child_count()):
		output_count += 1
		%Outputs.get_child(i).value = output_count
		%OutputLabel.get_child(i).text = str(output_count)


func _on_remove_output_button_pressed():
	if %OutputLabel.get_child_count() < 2:
		return
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var option_to_remove = %OutputLabel.get_child(-1)
	output_count -= 1
	option_to_remove.queue_free()
	%Outputs.get_child(-1).queue_free()
	%OutputButtons.position.y -= 50
	%ModeTitle.position.y -= 50
	%ModeSelection.position.y -= 50
	%Outline.size.y -= 50
	%ColorRect.size.y -= 50
	colision_polygon[2].y -= 50
	colision_polygon[3].y -= 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	if %OutputLabel.get_child_count() <= 3:
		$Sprite/OutputButtons/RemoveOutputButton.disabled = true


func _on_add_output_button_button_down():
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var new_output := output_node_scene.instantiate()
	var new_output_label := output_label_scene.instantiate()
	output_count += 1
	new_output.value = output_count
	new_output.is_standalone = false
	new_output.parent_node = self
	position_changed.connect(new_output._on_position_changed)
	z_index_changed.connect(new_output._on_z_index_changed)
	vs_nodes._on_output_added(new_output)

	new_output_label.text = str(output_count)
	%OutputLabel.add_child(new_output_label)
	%Outputs.add_child(new_output)
	%OutputButtons.position.y += 50
	%ModeTitle.position.y += 50
	%ModeSelection.position.y += 50
	%Outline.size.y += 50
	%ColorRect.size.y += 50
	colision_polygon[2].y += 50
	colision_polygon[3].y += 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	$Sprite/OutputButtons/RemoveOutputButton.disabled = false



func _on_mode_selection_item_selected(index):
	match index:
		0:
			title = "LoopSequence"
		1:
			title = "RepeatLastSequence"
		2:
			title = "StopSequence"
