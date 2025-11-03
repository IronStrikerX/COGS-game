extends Node2D

const CHARACTER = preload("uid://lmdupea46mc5")

@onready var characters: Node2D = $"../Characters"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in GameInfo.player_count:
		var new_character = CHARACTER.instantiate()
		new_character.player_id = i
		new_character.movement_speed = GameInfo.players_info[i]["movement speed"]
		new_character.cooking_speed = GameInfo.players_info[i]["cooking speed"]
		new_character.sabotage_speed = GameInfo.players_info[i]["sabotage speed"]
		characters.add_child(new_character)
		new_character.player_sprite.texture = GameInfo.player_sprite[i]
		print(GameInfo.players_info[i]["movement speed"], GameInfo.players_info[i]["cooking speed"],GameInfo.players_info[i]["sabotage speed"])
		new_character.global_position = Vector2(1000, 400 * i)
