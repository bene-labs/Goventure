extends VSNode


# Called when the node enters the scene tree for the first time.
func _ready():
	title = "say"
	super._ready()


func _on_dialogue_input_text_changed():
	param = %DialogueInput.text


func restore_configs(configs: Dictionary):
	super.restore_configs(configs)
	%DialogueInput.text = configs["text"]
	param = %DialogueInput.text


func serialize() -> Dictionary:
	var serial_data = super.serialize()
	serial_data["configs"]["text"] = %DialogueInput.text
	return serial_data
