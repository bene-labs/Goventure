extends Control

@export var button : PackedScene

@onready var action_buttons = %ActionButtons
@onready var first_item_buttons = %Item1Buttons
@onready var second_item_buttons = %Item2Buttons

var selected_item1 := ""
var selected_item2 := ""
var action := ""


func _ready():
	for action in Goventure.actions:
		var new_button = button.instantiate()
		new_button.name = action.title
		new_button.text = action.title
		action_buttons.add_child(new_button)
	for item in Goventure.interactables:
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


func _on_run_button_pressed():
	Goventure.run_action(action, selected_item1, selected_item2)
