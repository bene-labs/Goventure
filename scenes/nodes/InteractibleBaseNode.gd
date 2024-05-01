extends VSNode

@export var output_node : PackedScene
@export var output_label : PackedScene

func _ready():
	%Title.text = Goventure.interactibles[0]
	for action in Goventure.actions:
		var new_label := output_label.instantiate()
		new_label.text = action
		%OutputLabels.add_child(new_label)
		%Outputs.add_child(output_node.instantiate())
		%Outline.size.y += 50
		%ColorRect.size.y += 50
	super._ready()
	for output in outputs:
		output.set_state(TriState.State.FALSE)
