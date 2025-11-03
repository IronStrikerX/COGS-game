extends Control

@export var all_recipes: AllRecipes

@onready var character_select: Panel = %CharacterSelect
@onready var recipes: Panel = %Recipes
@onready var options: Panel = %Options

@onready var recipe_showcase_container: GridContainer = %RecipeShowcaseContainer
@onready var character_selected_container: HBoxContainer = %CharacterSelectedContainer
@onready var character_vbox_container: HBoxContainer = %CharacterVboxContainer

@onready var buffs_label: Label = %BuffsLabel
@onready var nerfs_label: Label = %NerfsLabel

@onready var recipe_showcase_scene = preload("uid://3odmco8wdgcg")
@onready var character_selecter_scene = preload("uid://dbmq8hnm207ux")
@onready var character_selected_scene = preload("uid://cxeihroida3jr")
var player_count := 0

var players_selected: Array = []

var character_info := {
	0: {"name" : "Regular",
		"texture" : preload("res://assets/RedGuy.png"),
		"movement speed" : 1,
		"cooking speed" : 1,
		"sabotage speed" : 1},
		
	1: {
		"name" : "movement",
		"texture" : preload("res://assets/BluePlayer.png"),
		"movement speed" : 1.2,
		"cooking speed" : 1.2,
		"sabotage speed" : 1},
		
	2: {
		"name" : "chef",
		"texture" : preload("res://assets/GreenGuy.png"),
		"movement speed" : 1,
		"cooking speed" : 0.8,
		"sabotage speed" : 1.2},
	3: {
		"name" : "sabotage",
		"texture" : preload("res://assets/PurpleGuy.png"),
		"movement speed" : 0.8,
		"cooking speed" : 1,
		"sabotage speed" : 0.8}
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_select.visible = true
	recipes.visible = false
	options.visible = false
	# === Character Select ===
	for i in range(4):
		var new_character = character_selecter_scene.instantiate()
		new_character.character_name = character_info[i]["name"]
		new_character.texture = character_info[i]["texture"]
		new_character.id = i
		new_character.clicked.connect(_on_character_select)
		new_character.hover.connect(_on_character_hover)
		character_vbox_container.add_child(new_character)
	
	for i in range(4):
		var new_character_selected = character_selected_scene.instantiate()
		players_selected.append(new_character_selected)
		character_selected_container.add_child(new_character_selected)
	
	# === Recipe Showcase ===
	for recipe in all_recipes.processable_recipe:
		var new_recipe = recipe_showcase_scene.instantiate()
		recipe_showcase_container.add_child(new_recipe)
		new_recipe.show_processable_recipe(recipe.requirement[0], recipe.appliance, recipe.item)
	
	for recipe in all_recipes.cookable_recipe:
		var new_recipe = recipe_showcase_scene.instantiate()
		recipe_showcase_container.add_child(new_recipe)
		new_recipe.show_cookable_recipe(recipe.requirement[0], recipe.requirement[1], recipe.item)



# when character panel is selected
func _on_character_select(texture: Texture, id: int) -> void:
	# player count starts at 0
	if player_count != 4:
		players_selected[player_count].character_selected(texture)
		GameInfo.players_info[player_count] = {"movement speed" : character_info[id]["movement speed"],
									"cooking speed" : character_info[id]["cooking speed"],
									"sabotage speed" : character_info[id]["sabotage speed"]}
		player_count += 1
		
func _on_character_hover(id: int, is_hovered: bool) -> void:
	if is_hovered:
		buffs_label.text = "Movement Multiplier: %s\nCooking Multiplier: %s \n Sabotage Multiplier: %s" % [character_info[id]["movement speed"], character_info[id]["cooking speed"], character_info[id]["sabotage speed"]]
	else:
		buffs_label.text = ""

func _on_play_button_pressed() -> void:
	character_select.visible = true
	recipes.visible = false
	options.visible = false

func _on_recipes_button_pressed() -> void:
	character_select.visible = false
	recipes.visible = true
	options.visible = false

func _on_options_button_pressed() -> void:
	character_select.visible = false
	recipes.visible = false
	options.visible = true

func _on_start_button_pressed() -> void:
	if player_count > 1:
		GameInfo.appliances = {
			"Oven" : player_count - 1, 
			"Stove" : player_count - 1,
			"Deep Fry Station" : player_count - 1,
			"Countertop" : player_count - 1,
			"Trash Bin" : player_count,
			"Assembly Station" : player_count
		}
		
		match player_count:
			2:
				GameInfo.kitchen_width = 3
				GameInfo.offset = Vector2(300,0)
			3:
				GameInfo.kitchen_width = 5
				GameInfo.offset = Vector2(200,0)
			4:
				GameInfo.kitchen_width = 7
				GameInfo.offset = Vector2(100,0)
				
		GameInfo.player_count = player_count
		
		get_tree().change_scene_to_file("res://Game/game.tscn")


func _on_clear_characters_selected_button_pressed() -> void:
	player_count = 0
	for character in character_selected_container.get_children():
		character.clear()
	GameInfo.players_info = {}
