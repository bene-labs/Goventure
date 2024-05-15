extends Node

var configs = Configs.new()


var actions : Array[Action] = [
	Action.new("default action", Action.CombinationType.OPTIONAL),
	Action.new("use", Action.CombinationType.OPTIONAL),
	Action.new("combine", Action.CombinationType.MANDTORY),
	Action.new("put into", Action.CombinationType.MANDTORY),
	Action.new("examine", Action.CombinationType.NONE),
	Action.new("talk", Action.CombinationType.NONE)]

var interactibles : Array[String] = ["Red Key", "Blue Lock", "Red Lock", "Door"]
var path_depths : Dictionary

var path_rid : String
var depth :
	set(value):
		path_depths[path_rid] = value
	get:
		var res = path_depths[path_rid] if path_rid in path_depths else 0
		return res

class Action:
	enum CombinationType {
		NONE,
		MANDTORY,
		OPTIONAL
	}
	
	var title := ""
	var combination_type : CombinationType
	
	func _init(title, combination_type):
		self.title = title
		self.combination_type = combination_type
