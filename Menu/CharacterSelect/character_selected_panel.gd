extends Panel

@onready var texture_rect: TextureRect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	print(texture_rect)
	
func character_selected(texture: Texture):
	texture_rect.texture = texture
