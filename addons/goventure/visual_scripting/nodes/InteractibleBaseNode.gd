extends VSNode

@export var output_node : PackedScene
@export var output_label : PackedScene


func _ready():
	%InteractibleSelection.clear()
	for interactible in Goventure.interactibles:
		%InteractibleSelection.add_item(interactible)
	%InteractibleSelection.selected = 0

	var colision_polygon = $Area2D/CollisionPolygon2D.polygon
	for action in Goventure.actions:
		var new_label := output_label.instantiate()
		new_label.text = action
		%OutputLabels.add_child(new_label)
		%Outputs.add_child(output_node.instantiate())
		%Outline.size.y += 50
		%ColorRect.size.y += 50
		colision_polygon[2].y += 50
		colision_polygon[3].y += 50
	$Area2D/CollisionPolygon2D.polygon = colision_polygon
	
	super._ready()
	for output in outputs:
		output.set_state(TriState.State.FALSE)
