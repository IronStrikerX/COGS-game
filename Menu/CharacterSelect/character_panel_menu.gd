extends Button

signal clicked(texture, id)
signal hover(id, is_hovered)

@onready var texture_rect: TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel

@export var texture: Texture
@export var character_name: String

var id: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texture:
		texture_rect.texture = texture
	if character_name:
		name_label.text = character_name


func _on_pressed() -> void:
	clicked.emit(texture, id)
	
func _on_mouse_entered() -> void:
	hover.emit(id, true)

func _on_mouse_exited() -> void:
	hover.emit(id, false)
