extends Node

var configs = Configs.new()


var actions : Array[String] = ["use", "combine", "examine"]
var interactibles : Array[String] = ["Red Key", "Blue Lock", "Red Lock", "Door"]
var path_depths : Dictionary

var path_rid : String
var depth :
	set(value):
		path_depths[path_rid] = value
	get:
		var res = path_depths[path_rid] if path_rid in path_depths else 0
		return res
