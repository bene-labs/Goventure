extends Control

@export var button : PackedScene
@export_dir var resource_dir = "res://addons/goventure/resources/interaction_data/"

@onready var action_buttons = %ActionButtons
@onready var first_item_buttons = %Item1Buttons
@onready var second_item_buttons = %Item2Buttons

var selected_item1 := ""
var selected_item2 := ""
var action := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	for action in Goventure.actions:
		var new_button = button.instantiate()
		new_button.name = action.title
		new_button.text = action.title
		action_buttons.add_child(new_button)
	for item in Goventure.interactibles:
		var new_button = button.instantiate()
		new_button.name = item
		new_button.text = item
		first_item_buttons.add_child(new_button)
		var new_button2 = button.instantiate()
		new_button2.name = item
		new_button2.text = item
		second_item_buttons.add_child(new_button2)
	

func _input(event):
	for button in first_item_buttons.get_children():
		if button.button_pressed:
			selected_item1 = button.text
	for button in action_buttons.get_children():
		if button.button_pressed:
			action = button.text
	for button in second_item_buttons.get_children():
		if button.button_pressed:
			if selected_item2 == button.text:
				selected_item2 = ""
			else:
				selected_item2 = button.text
	$ActionLabel.text = action + " " + selected_item1
	if selected_item2 != "":
		$ActionLabel.text += " with " + selected_item2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_run_button_pressed():
	var events : Array
	var path = resource_dir + "/" + selected_item1 + ".tres"
	if not ResourceLoader.exists(path):
		return
	var interactionData : InteractionData = ResourceLoader.load(path, "InteractionData")
	#var content = file.get_as_text()
	#var lines = content.split("\n")

	for command in interactionData.get_commands_by_action(action, \
		" " + selected_item2 if selected_item2 != "" else ""):
		events.append(command.value)

	#for i in range(lines.size()):
		#var line : String = lines[i]
		#if line.contains(action) and (selected_item2 == "" or line.contains(selected_item2)):
			#line = lines[i+1]
			#while line.contains("\t"):
				#events.push_back(line.substr(6, line.length() - 7))
				#i += 1
				#line = lines[i+1]
			#break
#
	if events.size() == 0:
		return

	var timeline : DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	Dialogic.start(timeline)
