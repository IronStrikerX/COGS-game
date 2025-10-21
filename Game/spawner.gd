extends Node2D
const APPLIANCES = preload("uid://brrm84npst7bp")

const WIDTH := 8
const HEIGHT := 7
const CELL_SIZE := Vector2(98,98)

var all_cells = []

@export var list_of_appliances = {
	"Oven" : 3,
	"Stove" : 3,
	"Deep Fry Station" : 3,
	"Assembly Station" : 2,
	"Countertop" : 3,
	"Trash Bin" : 2
}

func _ready():
	for x in range (WIDTH):
		for y in range (HEIGHT):
			all_cells.append(Vector2(x,y))
	spawn_appliances()
			
func spawn_appliances():
	var appliances = []
	for appliance in list_of_appliances:
		var number = list_of_appliances[appliance]
		for i in range(number):
			print("added ", appliance)
			appliances.append(appliance)
			
	var available_cells = all_cells.duplicate()
	var assembly_station_count = 1
	
	for i in range(appliances.size()):
		if available_cells.size() == 0:
			print("No more space to spawn appliances!")
			break
		
		# Pick a random cell and remove it from available_cells
		var index = randi_range(0, available_cells.size() - 1)
		var cell = available_cells[index]
		available_cells.remove_at(index)
		# Convert grid cell to world position
		var world_pos = cell * CELL_SIZE + CELL_SIZE / 2
		# Instance and place the applianc
		var new_appliance = APPLIANCES.instantiate()
		var appliance_type = appliances.pick_random()
		appliances.erase(appliance_type)
		new_appliance.position = world_pos
		new_appliance.z_index = int(cell.y)
		match appliance_type:
			"Oven":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.OVEN
			"Stove":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.STOVE
			"Deep Fry Station":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.DEEP_FRY_STATION
			"Countertop":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.COUNTERTOP
			"Trash Bin":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.TRASH_BIN
			"Assembly Station":
				new_appliance.appliance_type = CookingRecipe.ApplianceType.ASSEMBLY_STATION
				new_appliance.assembly_station_owner = assembly_station_count
				print("spawned")
				assembly_station_count += 1
		
		add_child(new_appliance)
