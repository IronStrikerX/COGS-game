extends Node2D
const APPLIANCES = preload("uid://brrm84npst7bp")

@export var WIDTH : int
@export var HEIGHT : int

const CELL_SIZE := Vector2(100, 100)

var all_cells = []
var assembly_station_count = 1

@export var list_of_appliances = {
	"Oven" : 3,
	"Stove" : 3,
	"Deep Fry Station" : 3,
	"Countertop" : 3,
	"Trash Bin" : 2,
	"Assembly Station" : 2,
}

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		all_cells = []
		assembly_station_count = 1
		for y in range(HEIGHT):
			for x in range(WIDTH):
				all_cells.append(Vector2(x, y))
		for child in get_children():
			child.queue_free()
			
		var grid = generate_map()
		spawn_map(grid)
		print_grid(grid)

func print_grid(grid):
	print("\t")
	for y in range(HEIGHT):
		var row = " "
		for x in range(WIDTH):
			row += str(grid[y][x]) + " "
		print(row)
	
	
		
func spawn_map(grid):
	var appliances = []
	
	for appliance in list_of_appliances:
		var number = list_of_appliances[appliance]
		for i in range(number):
			appliances.append(appliance)
	
	var available_appliance_space = []
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if grid[y][x] == 1: available_appliance_space.append(Vector2(x, y))
	
	for i in range(available_appliance_space.size()):
		var location = available_appliance_space.pick_random()
		available_appliance_space.erase(location)
		
		var world_pos = location * CELL_SIZE + CELL_SIZE / 2
		var new_appliance = APPLIANCES.instantiate()
		var appliance_type = appliances.pick_random()
		appliances.erase(appliance_type)
		new_appliance.position = world_pos + Vector2(200, 0)
		new_appliance.z_index = int(location.x + location.y)
		
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
				assembly_station_count += 1
		
		add_child(new_appliance)


func generate_map():
	# 0 = empty, 1 = appliance
	var grid = []
	for y in range(HEIGHT):
		var row = []
		for x in range(WIDTH):
			row.append(0)
		grid.append(row)
		
	@warning_ignore("integer_division")
	
	# Flatten appliance counts
	var appliance_cells = 0
	for appliance in list_of_appliances:
		for i in range(list_of_appliances[appliance]):
			appliance_cells += 1
	
	var placed = 0
	
	while placed < appliance_cells:
		var cell = all_cells.pick_random()
		# Skip perimeter
		# if cell.x == 0 or cell.x == WIDTH-1 or cell.y == 0 or cell.y == HEIGHT-1:
			# continue
		# Skip if already occupied
		if grid[cell.y][cell.x] != 0:
			continue
		# Check neighbors to ensure at least one open space
		var free_neighbors = 0
		for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
			var nx = cell.x + dir.x
			var ny = cell.y + dir.y
			if nx >=0 and nx < WIDTH and ny >= 0 and ny < HEIGHT:
				if grid[ny][nx] == 0:
					free_neighbors += 1
		if free_neighbors == 0:
			continue  # skip, would block access
		
		# Place appliance
		grid[cell.y][cell.x] = 1
		placed += 1
	
	# Optional: BFS check to ensure all appliances are reachable
	if not check_all_accessible(grid):
		return generate_map()  # regenerate if blocked
	
	return grid

# BFS to ensure all appliances are reachable from a starting empty cell
func check_all_accessible(grid):
	# Collect all empty cells
	var empty_cells = []
	for y in range(HEIGHT):
		for x in range(WIDTH):
			if grid[y][x] == 0:
				empty_cells.append(Vector2(x, y))
	
	# Try BFS from every empty cell
	for start in empty_cells:
		# Initialize visited matrix
		var visited = []
		for y in range(HEIGHT):
			var row = []
			for x in range(WIDTH):
				row.append(false)
			visited.append(row)
		
		var queue = [start]
		visited[start.y][start.x] = true
		
		# BFS traversal
		while queue.size() > 0:
			var current = queue.pop_front()
			for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
				var nx = current.x + dir.x
				var ny = current.y + dir.y
				if nx >= 0 and nx < WIDTH and ny >= 0 and ny < HEIGHT:
					if not visited[ny][nx] and grid[ny][nx] != 1:
						visited[ny][nx] = true
						queue.append(Vector2(nx, ny))
		
		# Check if all appliances have at least one reachable neighbor
		var all_accessible = true
		for y in range(HEIGHT):
			for x in range(WIDTH):
				if grid[y][x] == 1:
					var accessible = false
					for dir in [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]:
						var nx = x + dir.x
						var ny = y + dir.y
						if nx >= 0 and nx < WIDTH and ny >= 0 and ny < HEIGHT:
							if visited[ny][nx]:
								accessible = true
								break
					if not accessible:
						all_accessible = false
						break
			if not all_accessible:
				break
		
		# If BFS from this start reached all appliances, return true immediately
		if all_accessible:
			return true
		
	# If no starting empty cell can reach all appliances, return false
	return false
