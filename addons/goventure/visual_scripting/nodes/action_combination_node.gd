class_name ActionCombinationNode
extends VSNode

@onready var interactable_selection = %InteractableSelection


func _ready():
	title = "with"
	interactable_selection.clear()
	for interactable in Goventure.interactables:
		interactable_selection.add_item(interactable)
	interactable_selection.selected = 0
	param = interactable_selection.get_item_text(interactable_selection.selected)
	super._ready()
	$Inputs/Input.value_changed.connect(_on_input_value_changed)


func _on_input_value_changed():
	$Outputs/Output.set_value($Inputs/Input.value)


func _on_interactable_selection_item_selected(index):
	param = interactable_selection.get_item_text(index)


func restore_configs(configs: Dictionary):
	super.restore_configs(configs)
	if configs["selected"] < interactable_selection.item_count:
		interactable_selection.selected = configs["selected"]
	param = interactable_selection.get_item_text(interactable_selection.selected)


func serialize() -> Dictionary:
	var serial_data = super.serialize()
	serial_data["configs"]["selected"] = interactable_selection.selected
	return serial_data
