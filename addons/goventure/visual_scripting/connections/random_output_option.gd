extends HBoxContainer

signal weight_changed(amount, source)

var weight = 1 :
	set(value):
		if value < 0:
			return
		var difference = value - weight
		weight = value
		weight_changed.emit(difference, self)
		$Label.text = str(weight) + " / " + str(max_weight)
	get: return weight
var max_weight = 2 :
	set(value):
		max_weight = value
		$Label.text = str(weight) + " / " + str(max_weight)
	get: return max_weight


func _on_minus_button_pressed():
	weight -= 1


func _on_plus_button_pressed():
	weight += 1
