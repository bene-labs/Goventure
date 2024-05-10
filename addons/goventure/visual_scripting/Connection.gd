class_name Connection extends Control

signal value_changed
signal clicked(node)
signal released_over(node)
signal position_changed(new_pos)

enum ConnectionType {
	ACTION,
	FLOW
}

@onready var wire = get_node_or_null("InteractionPoint/Wire")
@onready var interactionSprite : TextureRect = %InteractionPoint
@onready var base_scale = interactionSprite.scale

var collision_radius = 26.0
var undefined_color = Color.RED
var off_color = Color("545151")
var on_color = Color("241ec9")
var inactive_color = Color("b1e2f1")
var active_color = Color("65c2dd")

var parent_node : VSNode

var is_hovered : bool = false
var is_active : bool = false
var is_standalone = true

var value = null
#var value_type := Variant.Type.TYPE_NIL
var is_dragged = false
var drag_offset = Vector2.ZERO
var is_mouse_movement = false

func _ready():
	interactionSprite.self_modulate = inactive_color
	CursorCollision.register(self)

func set_value(value):
	self.value = value
	
	$DelayTimer.wait_time = Goventure.configs.simulation_speed
	$DelayTimer.start()
	await $DelayTimer.timeout
	value_changed.emit()


func get_attachment_point():
	return %AttachmentPoint.global_position


func is_point_inside(point):
	return get_attachment_point().distance_to(point) <= collision_radius


func _on_mouse_entered():
	interactionSprite.scale = base_scale * 1.25
	is_hovered = true
	
func _on_mouse_exited():
	interactionSprite.scale = base_scale
	is_hovered = false
	
func set_active():
	is_active = true
	interactionSprite.self_modulate = active_color
	
func set_inactive():
	is_active = false
	interactionSprite.self_modulate = inactive_color

func _input(event):
	if not is_hovered:
		return
	
	is_mouse_movement = true if event is InputEventMouseMotion and event.relative else false
	
	if Input.is_action_just_pressed("cable"):
		clicked.emit(self)
	elif is_active and Input.is_action_just_released("cable"):
		released_over.emit(self)
	elif is_standalone and Input.is_action_just_pressed("drag_connection"):
		is_dragged = true
		drag_offset = global_position - get_global_mouse_position()
		CursorCollision.lock()
	elif is_dragged and Input.is_action_just_released("drag_connection"):
		is_dragged = false
		CursorCollision.unlock()

func _process(delta):
	if !is_dragged or !is_mouse_movement:
		return
	set_position(get_global_mouse_position() + drag_offset)
	_on_position_changed()
	
func can_connect(other : Connection):
	return false

func _on_z_index_changed(new_index):
	pass


@warning_ignore("native_method_override")
func set_z_index(value, wire_offset = 0):
	z_index = value
	if wire == null:
		return
	wire.z_index = wire_offset


func _on_position_changed():
	position_changed.emit(get_attachment_point())


func _exit_tree():
	CursorCollision.unregister(self)
