extends VSNode

@export var output_node_scene : PackedScene
@export var output_option_scene : PackedScene

var total_weight = 0 :
	set(value):
		total_weight = value
		_on_total_weight_changed()
	get: return total_weight


func _ready():
	super._ready()
	for option in %OutputOptions.get_children(false):
		option.weight_changed.connect(_on_output_weight_changed)
		total_weight += 1


func _on_remove_output_button_pressed():
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var option_to_remove = %OutputOptions.get_child(-1)
	total_weight -= option_to_remove.weight
	option_to_remove.queue_free()
	%Outputs.get_child(-1).queue_free()
	%OutputButtons.position.y -= 50
	%Outline.size.y -= 50
	%ColorRect.size.y -= 50
	colision_polygon[2].y -= 50
	colision_polygon[3].y -= 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon


func _on_add_output_button_button_down():
	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	var new_output := output_node_scene.instantiate()
	var new_output_option := output_option_scene.instantiate()
	new_output_option.weight_changed.connect(_on_output_weight_changed)
	%OutputOptions.add_child(new_output_option)
	%Outputs.add_child(new_output)
	%OutputButtons.position.y += 50
	%Outline.size.y += 50
	%ColorRect.size.y += 50
	colision_polygon[2].y += 50
	colision_polygon[3].y += 50
	total_weight += 1
	$Area2D/CollisionPolygon2D.polygon = colision_polygon


func _on_total_weight_changed():
	for output in %OutputOptions.get_children(false):
		output.max_weight = total_weight


func _on_output_weight_changed(value_change, source):
	if source.weight <= 0 and value_change < 0:
		return
	source.weight += value_change
	total_weight += value_change