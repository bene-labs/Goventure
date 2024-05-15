class_name CableConnection extends Connection


func _ready():
	super._ready()
	is_standalone = true
	inactive_color = Color.WHITE_SMOKE
	active_color = Color.DARK_GRAY
