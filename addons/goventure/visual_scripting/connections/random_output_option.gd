extends HBoxContainer

signal weight_changed(amount, source)

var weight = 1 :
	set(value):
		weight = value
		$Label.text = str(weight) + " / " + str(max_weight)
	get: return weight
var max_weight = 2 :
	set(value):
		max_weight = value
		$Label.text = str(weight) + " / " + str(max_weight)
	get: return max_weight


func _on_minus_button_pressed():
	weight_changed.emit(-1, self)


func _on_plus_button_pressed():
	weight_changed.emit(1, self)
