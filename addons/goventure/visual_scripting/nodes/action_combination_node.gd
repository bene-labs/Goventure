class_name ActionCombinationNode
extends VSNode

@onready var interactible_selection = %InteractibleSelection

# Called when the node enters the scene tree for the first time.
func _ready():
	title = "with"
	interactible_selection.clear()
	for interactible in Goventure.interactibles:
		interactible_selection.add_item(interactible)
	interactible_selection.selected = 0
	param = interactible_selection.get_item_text(interactible_selection.selected)
	super._ready()
	$Inputs/Input.value_changed.connect(_on_input_value_changed)

func _on_input_value_changed():
	$Outputs/Output.set_value($Inputs/Input.value)

func _on_interactible_selection_item_selected(index):
	param = interactible_selection.get_item_text(index)