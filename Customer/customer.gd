extends Area2D

@export var possible_demands: CustomerDemands
@export var all_recipes: AllRecipes

@onready var food_desired: Sprite2D = $FoodDesired
@onready var panel: Panel = $Panel
@onready var progress_bar: ProgressBar = $Panel/ProgressBar

var required_food: FoodResource

var is_waiting: bool = false
var wait_timer: float
var patience: float
var num_recursion: int

func _ready() -> void:
	add_to_group("customer")
	new_demand()

func receive_food(recieved_food: FoodResource) -> bool:
	if recieved_food == required_food:
		new_demand()
		return true
	return false
	
func new_demand():
	required_food = possible_demands.meals.pick_random()
	food_desired.texture = required_food.texture
	num_recursion = 0
	patience = get_total_cook_time(required_food) + (randf_range(2, 4) * 4 * (log(num_recursion) + 1))
	start_processing()

func set_highlight(x: bool):
	panel.modulate = Color(0.521, 0.533, 0.521, 1.0) if x else Color(1.0, 1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	if is_waiting:
		wait_timer -= delta
		progress_bar.value = wait_timer / patience
			
		if wait_timer <= 0:
			complete_processing()
		
func start_processing():
	is_waiting = true
	wait_timer = patience
	progress_bar.visible = true
	progress_bar.value = 1

func complete_processing():
	is_waiting = false
	progress_bar.visible = false
	new_demand()

# find the total amount of time it would take to prepare the meal using recursion
func get_total_cook_time(food: FoodResource) -> float:
	# trying to find a recipe for this food
	for recipe in all_recipes.recipes:
		if recipe.item == food:
			var total_time := recipe.time_required
			
			# For each ingredient recursively get its time
			for ingredient in recipe.requirement:
				total_time += get_total_cook_time(ingredient)
			
			num_recursion += 1
			return total_time
	# can't find any recipe meaning this is a base food (Potato, Buns, Meat)
	return 0
