extends VSNode

@export var output_node_scene : PackedScene
@export var output_option_scene : PackedScene

const OUTPUT_HEIGHT = 52

var total_weight = 0 :
	set(value):
		total_weight = value
		_on_total_weight_changed()
		param = total_weight
	get: return total_weight


func _ready():
	super._ready()
	title = "Random"
	for option in %OutputOptions.get_children(false):
		option.weight_changed.connect(_on_output_weight_changed)
		_on_output_weight_changed(option.weight, option)


func _on_remove_output_button_pressed():
	if %OutputOptions.get_child_count() < 2:
		return
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var option_to_remove = %OutputOptions.get_child(-1)
	total_weight -= option_to_remove.weight
	option_to_remove.queue_free()
	%Outputs.get_child(-1).queue_free()
	%OutputButtons.position.y -= OUTPUT_HEIGHT
	%Outline.size.y -= OUTPUT_HEIGHT
	%ColorRect.size.y -= OUTPUT_HEIGHT
	colision_polygon[2].y -= OUTPUT_HEIGHT
	colision_polygon[3].y -= OUTPUT_HEIGHT
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	if %OutputOptions.get_child_count() <= 3:
		$Sprite/OutputButtons/RemoveOutputButton.disabled = true


func _on_add_output_button_button_down():
	add_output()


func add_output(output_scene = output_node_scene):
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var new_output := output_scene.instantiate()
	var new_output_option := output_option_scene.instantiate()
	
	new_output.is_standalone = false
	new_output.parent_node = self
	position_changed.connect(new_output._on_position_changed)
	z_index_changed.connect(new_output._on_z_index_changed)
	vs_nodes._on_connection_added(new_output)
	
	new_output_option.weight_changed.connect(_on_output_weight_changed)
	%OutputOptions.add_child(new_output_option)
	%Outputs.add_child(new_output)
	_on_output_weight_changed(new_output_option.weight, new_output_option)
	
	%OutputButtons.position.y += OUTPUT_HEIGHT
	%Outline.size.y += OUTPUT_HEIGHT
	%ColorRect.size.y += OUTPUT_HEIGHT
	colision_polygon[2].y += OUTPUT_HEIGHT
	colision_polygon[3].y += OUTPUT_HEIGHT
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	$Sprite/OutputButtons/RemoveOutputButton.disabled = false


func _on_total_weight_changed():
	for option in %OutputOptions.get_children(false):
		option.max_weight = total_weight


func _on_output_weight_changed(value_change, source):
	for i in range(%Outputs.get_child_count()):
		if %OutputOptions.get_child(i) == source:
			%Outputs.get_child(i).value = source.weight
			break
	total_weight += value_change


func restore_configs(configs: Dictionary):
	if not "additional_outputs" in configs:
		super.restore_configs(configs)
		return
	
	if not "additional_outputs" in configs:
		return
	for output in configs["additional_outputs"]:
		add_output(load(output["path"]))
	await get_tree().process_frame
	super.restore_configs(configs)


func serialize() -> Dictionary:
	var serial_data = super.serialize()
	if %Outputs.get_child_count() <= 2:
		return serial_data
	serial_data["configs"]["additional_outputs"] = []
	for i in range(2, %Outputs.get_child_count()):
		serial_data["configs"]["additional_outputs"].push_back(%Outputs.get_child(i).serialize())
	return serial_data
