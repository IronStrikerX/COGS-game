extends StaticBody2D

@export var appliance_type: CookingRecipe.ApplianceType
@export var assembly_station_owner: int = -1
@export var spoil_time: float = 5

@onready var selected_food_sprite: Sprite2D = %SelectedFood
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var appliance_label: Label = $Sprite2D/Control/ApplianceLabel
@onready var cook_bar: ProgressBar = $Sprite2D/Control/ProgressBar
@onready var spoil_bar: ProgressBar = $Sprite2D/Control/SpoilProgressBar
@onready var smoke_particle: CPUParticles2D = $SmokeParticle

var selected_food: FoodResource
var available_process_recipes: AllRecipes = preload("uid://bj0t716heki1a")
var available_cookable_recipes: AllRecipes = preload("uid://bx0qv0eh20yw2")

var is_cooking: bool = false
var is_spoiling: bool = false
var process_timer: float = 0.0
var process_time: float

var player_color = {
	1: Color(0.0, 0.0, 1.0, 1.0),
	2: Color(0.0, 1.0, 0.0, 1.0),
	3: Color(1.0, 0.0, 0.0, 1.0),
	4: Color(0.447, 0.002, 0.976, 1.0)
}

var current_player_using: int

func _ready() -> void:
	cook_bar.visible = false
	cook_bar.value = 0
	spoil_bar.visible = false
	spoil_bar.value =0
	smoke_particle.emitting = false
	
	selected_food_sprite.texture = null
	
	add_to_group("appliance")
	
	match appliance_type:
		CookingRecipe.ApplianceType.OVEN:
			appliance_label.text = "Oven"
		CookingRecipe.ApplianceType.STOVE:
			appliance_label.text = "Stove"
		CookingRecipe.ApplianceType.DEEP_FRY_STATION:
			appliance_label.text = "Deep Fry Station"
		CookingRecipe.ApplianceType.COUNTERTOP:
			appliance_label.text = "Countertop"
		CookingRecipe.ApplianceType.TRASH_BIN:
			appliance_label.text = "Trash Bin"
		CookingRecipe.ApplianceType.ASSEMBLY_STATION:
			appliance_label.text = "Assembly Station"
			sprite_2d.modulate = player_color[assembly_station_owner].lightened(0.65)

func _process(delta: float) -> void:
	if is_cooking:
		process_timer += delta
		cook_bar.value = process_timer / process_time
		
		if process_timer >= process_time:
			complete_processing()
			
	elif is_spoiling:
		process_timer += delta
		spoil_bar.value = process_timer / spoil_time
		if process_timer >= spoil_time:
			complete_spoiling()

func start_processing():
	is_cooking = true
	process_timer = 0.0
	cook_bar.visible = true
	cook_bar.value = 0

func complete_processing():
	is_cooking = false
	cook_bar.visible = false
	if appliance_type != CookingRecipe.ApplianceType.ASSEMBLY_STATION and appliance_type != CookingRecipe.ApplianceType.COUNTERTOP:
		# start spoiling
		is_spoiling = true
		process_timer = 0
		spoil_bar.visible = true
		smoke_particle.amount = 15

func complete_spoiling():
	selected_food = null
	selected_food_sprite.texture = null
	reset_spoil_bar()

func reset_spoil_bar():
	is_spoiling = false
	spoil_bar.visible = false
	spoil_bar.value = 0
	smoke_particle.emitting = false

# make sure player can give food to appliance
func receive_food(recieved_food: FoodResource, player_id: int) -> bool:
	# trash bin
	if appliance_type ==  CookingRecipe.ApplianceType.TRASH_BIN:
		return true
		
	#  Duplicate the styleboxes before editing them so they don't override
	var fill_box = cook_bar.get("theme_override_styles/fill")
	fill_box = fill_box.duplicate()
	fill_box.bg_color = player_color[player_id].lightened(0.3)
	cook_bar.add_theme_stylebox_override("fill", fill_box)
	
	var bg_box = spoil_bar.get("theme_override_styles/background")
	bg_box = bg_box.duplicate()
	bg_box.bg_color = player_color[player_id].lightened(0.3)
	spoil_bar.add_theme_stylebox_override("background", bg_box)
	
	# assembly station or countertop
	if appliance_type == CookingRecipe.ApplianceType.ASSEMBLY_STATION or appliance_type == CookingRecipe.ApplianceType.COUNTERTOP:
		# if appliance is assembly station, it makes sure the player is using theirs
		if appliance_type == CookingRecipe.ApplianceType.ASSEMBLY_STATION: 
			if assembly_station_owner != player_id:
				return false
				
		# if theres already food on counter then it will try looking for available recipes
		if selected_food:
			var cooked_food = cookable_food(recieved_food)
			# checks if a recipe is available
			if cooked_food:
				selected_food = cooked_food
				selected_food_sprite.texture = cooked_food.texture
				return true
			else:
				print(cooked_food)
				return false
		# no selected food means the food given is the selected food
		else:
			selected_food = recieved_food
			selected_food_sprite.texture = selected_food.texture
			return true

	# appliances can only have one selected food
	else:
		if not selected_food:
			current_player_using = player_id
			var processed_food = process_food(recieved_food)
			# checks if this appliance plus recieved food can create something
			if processed_food:
				selected_food = processed_food
				selected_food_sprite.texture = processed_food.texture
				return true
			else:
				return false
		return false

func give_food(player_id: int) -> FoodResource:
	# checks if there is food on appliance and its not cooking 
	if selected_food and not is_cooking:
		if appliance_type != CookingRecipe.ApplianceType.COUNTERTOP:
			# checks if the player who cooked is picking it up
			if appliance_type == CookingRecipe.ApplianceType.ASSEMBLY_STATION:
				if assembly_station_owner != player_id: return null
			else:
				if current_player_using != player_id: return null
		
		var food_to_give = selected_food
		selected_food = null
		selected_food_sprite.texture = null
		
		reset_spoil_bar()
		return food_to_give
	return null

func set_highlight(x: bool):
	if appliance_type == CookingRecipe.ApplianceType.ASSEMBLY_STATION:
		sprite_2d.modulate = Color(0.521, 0.533, 0.521, 1.0) if x else player_color[assembly_station_owner].lightened(0.65)
	else:
		sprite_2d.modulate = Color(0.521, 0.533, 0.521, 1.0) if x else Color(1.0, 1.0, 1.0, 1.0)

func process_food(recieved_food: FoodResource) -> FoodResource:
	if selected_food or not recieved_food:
		return null
		
	for recipe in available_process_recipes.recipes:
		# Only check recipes for this appliance type
		if recipe.appliance != appliance_type:
			continue
		
		#if the selected_food and appliance is a recipe for something
		if recieved_food == recipe.requirement[0]:
			process_time = recipe.time_required
			smoke_particle.amount = 3
			smoke_particle.emitting = true
			start_processing()
			
			print("Processed using ", str(appliance_type))
			return recipe.item

	print("No matching processed recipe found for", str(appliance_type))
	return null

func cookable_food(recieved_food: FoodResource) -> FoodResource:
	if not selected_food or not recieved_food:
		print("no selected food or recieved food")
		return null
	
	for recipe in available_cookable_recipes.recipes:
		
		# Map to names using Array comprehension
		var requirement_names = []
		for f in recipe.requirement:
			requirement_names.append(f.name)
		
		var current_names = []
		for f in [selected_food, recieved_food]:
			current_names.append(f.name)
		
		# Sort to ignore order
		requirement_names.sort()
		current_names.sort()
		
		if requirement_names == current_names:
			process_time = recipe.time_required
			start_processing()
			return recipe.item
	print("no recipe")
	return null
