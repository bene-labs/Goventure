class_name InputConnection extends Connection

var connected_input = null


func _ready():
	super._ready()
	
	self_modulate = undefined_color


func can_connect(other: Connection) -> bool:
	if not super.can_connect(other):
		return false
	if other is InputConnection:
		return false
	return true
