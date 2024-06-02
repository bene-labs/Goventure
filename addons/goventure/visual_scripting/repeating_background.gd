extends Control

@export var background_scene : PackedScene
@export var background_base_dimensions : Vector2
@export var repeat_count := Vector2(25, 25)


func _ready():
	for y in range(repeat_count.y):
		for x in range(repeat_count.x):
			var background = background_scene.instantiate()
			background.position = \
				Vector2((x - repeat_count.x / 2) * background_base_dimensions.x,  
						(y - repeat_count.y / 2) * background_base_dimensions.y)
			add_child(background)
