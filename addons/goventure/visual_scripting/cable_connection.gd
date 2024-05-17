class_name CableConnection extends Connection


func _ready():
	super._ready()
	is_standalone = true
	inactive_color = Color.WHITE_SMOKE
	active_color = Color.DARK_GRAY

func can_connect(other: Connection):
	if other is InputConnection:
		for output in get_all_connections() \
			.filter(func(x): return not x.is_standalone and x is Output):
			if not output.can_connect(other):
				return false
	elif other is Output:
		for input in get_all_connections() \
			.filter(func(x): return not x.is_standalone and x is InputConnection):
			if not input.can_connect(other):
				return false
	else:
		for connection in get_all_connections() \
			.filter(func(x): return not x.is_standalone):
			if not other.can_connect(connection):
				return false
	return true
