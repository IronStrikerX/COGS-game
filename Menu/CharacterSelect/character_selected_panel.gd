extends Panel

@onready var texture_rect: TextureRect = $TextureRect
	
func character_selected(texture: Texture) -> void:
	texture_rect.texture = texture

func clear() :
	texture_rect.texture = null
