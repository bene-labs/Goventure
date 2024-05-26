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
	add_output()


func add_output(output_scene = output_node_scene):
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var new_output := output_scene.instantiate()
	var new_output_label := output_label_scene.instantiate()
	output_count += 1
	new_output.value = output_count
	new_output.is_standalone = false
	new_output.parent_node = self
	position_changed.connect(new_output._on_position_changed)
	z_index_changed.connect(new_output._on_z_index_changed)
	vs_nodes._on_connection_added(new_output)

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


func restore_configs(configs: Dictionary):
	%ModeSelection.selected = configs["selected"]
	_on_mode_selection_item_selected(%ModeSelection.selected)
	if not "additional_outputs" in configs:
		super.restore_configs(configs)
		return
	for output in configs["additional_outputs"]:
		add_output(load(output["path"]))
	super.restore_configs(configs)

func serialize() -> Dictionary:
	var serial_data = super.serialize()
	serial_data["configs"]["selected"] = %ModeSelection.selected
	if %Outputs.get_child_count() <= 2:
		return serial_data
	serial_data["configs"]["additional_outputs"] = []
	for i in range(2, %Outputs.get_child_count()):
		serial_data["configs"]["additional_outputs"].push_back(%Outputs.get_child(i).serialize())
	return serial_data
