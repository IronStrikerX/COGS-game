extends Node2D

@export var food: FoodResource
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	sprite_2d.texture = food.texture
	label.text = food.name
	add_to_group("food")
