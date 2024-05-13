extends VSNode


# Called when the node enters the scene tree for the first time.
func _ready():
	title = "say"
	param = '\"\"'
	super._ready()

func _on_dialogue_input_text_changed():
	param = '\"' + %DialogueInput.text + '\"'
