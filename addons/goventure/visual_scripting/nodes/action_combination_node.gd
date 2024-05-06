extends VSNode


# Called when the node enters the scene tree for the first time.
func _ready():
	%InteractibleSelection.clear()
	for interactible in Goventure.interactibles:
		%InteractibleSelection.add_item(interactible)
	super._ready()
