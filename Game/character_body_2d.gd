extends CharacterBody2D

const SPEED = 500.0
const DROP_TIME = 1.5

@export var player_id: int

@onready var selected_food_sprite: Sprite2D = %SelectedFood
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var drop_bar: ProgressBar = $DropBar
@onready var drop_timer: Timer = $DropTimer

var object: Area2D = null
var nearby_appliances: Array[StaticBody2D] = []
var current_appliance: StaticBody2D = null
var current_customer: Area2D = null

var selected_food: FoodResource = null
var holding_drop: bool = false
var hold_time: float = 0.0
var hold_buffer: float = 0.2

var try_swap_already := false

func _ready():
	match player_id:
		1: 
			player_sprite.texture = preload("uid://ua4v1jbf0f11")
		2:
			player_sprite.texture = preload("uid://5fnneva0kop")
			

func _physics_process(delta: float) -> void:
	var prefix = "p%d_" % player_id
	
	# --- Movement ---
	var x_mov = Input.get_action_strength(prefix + "right") - Input.get_action_strength(prefix + "left")
	var y_mov = Input.get_action_strength(prefix + "down") - Input.get_action_strength(prefix + "up")
	var mov = Vector2(x_mov, y_mov)
	velocity = mov.normalized() * SPEED
	move_and_slide()
	
	# --- Action Key ---
	if Input.is_action_just_pressed(prefix + "action"):
		# Single tap behavior: try instant swap/pickup
		if not selected_food:
			try_pickup()
		elif selected_food:
			# Attempt instant swap if appliance or customer supports it
			if current_appliance and current_appliance.has_method("receive_food"):
				if current_appliance.receive_food(selected_food, player_id):
					clear_selected_food()
			elif current_customer and current_customer.has_method("receive_food"):
				if current_customer.receive_food(selected_food):
					clear_selected_food()
		# Start hold timer
		holding_drop = true
		hold_time = 0
		

	elif Input.is_action_pressed(prefix + "action") and holding_drop and selected_food:
		# Holding: increment timer
		hold_time += delta
		if hold_time >= hold_buffer:
			drop_bar.visible = true
			drop_bar.value = clamp(hold_time / DROP_TIME, 0, 1)
			if hold_time >= DROP_TIME:
				# Drop food after hold time
				if current_appliance and current_appliance.has_method("receive_food"):
					current_appliance.receive_food(selected_food, player_id)
				clear_selected_food()
				holding_drop = false
				drop_bar.visible = false

	elif Input.is_action_just_released(prefix + "action"):
		# Reset hold state if released early
		holding_drop = false
		hold_time = 0
		drop_bar.value = 0
		drop_bar.visible = false

	 


# --- Pickup Logic ---
func try_pickup():
	# Pick up from object in world
	if object:
		selected_food = object.get_parent().food
		selected_food_sprite.texture = selected_food.texture
		return
	
	# Pick up from appliance
	if current_appliance and current_appliance.has_method("give_food"):
		var received = current_appliance.give_food(player_id)
		if received:
			selected_food = received
			selected_food_sprite.texture = selected_food.texture
			print("Picked up %s from %s" % [received.name, str(current_appliance.appliance_type)])
			return


# --- Drop / Swap Logic ---
func try_swap():
	# Drop at appliance
	try_swap_already = true
	if current_appliance and current_appliance.has_method("receive_food"):
		if current_appliance.receive_food(selected_food, player_id):
			# Drop successful
			clear_selected_food()
		elif current_appliance.appliance_type in [CookingRecipe.ApplianceType.COUNTERTOP, CookingRecipe.ApplianceType.ASSEMBLY_STATION]:
			# Try swap
			var appliance_food = current_appliance.give_food(player_id)
			if appliance_food and current_appliance.receive_food(selected_food, player_id):
				# Swap successful
				selected_food = appliance_food
				if selected_food:
					selected_food_sprite.texture = selected_food.texture
				else:
					clear_selected_food()
		return
	
	# Give to customer
	if current_customer and current_customer.has_method("receive_food"):
		if current_customer.receive_food(selected_food):
			clear_selected_food()
		return


# --- Helper to clear food ---
func clear_selected_food():
	selected_food = null
	selected_food_sprite.texture = null


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("food"):
		object = area
		
	elif area.get_parent().is_in_group("appliance"):
		nearby_appliances.append(area.get_parent())
		update_current_appliance()
	
	elif area.is_in_group("customer"):
		current_customer = area
		current_customer.set_highlight(true)
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area == object:
		object = null
		
	if area.get_parent().is_in_group("appliance"):
			nearby_appliances.erase(area.get_parent())
			update_current_appliance()
			
	if area.is_in_group("customer"):
		current_customer.set_highlight(false)
		current_customer = null
		

func update_current_appliance() -> void:
	var closest: StaticBody2D = null
	var closest_dist = INF
	
	#find the clostes appliance to the player
	for appliance in nearby_appliances:
		var dist = global_position.distance_to(appliance.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = appliance
	
	# update highlight states
	if current_appliance and current_appliance != closest:
		current_appliance.set_highlight(false)
	
	current_appliance = closest
	
	if current_appliance:
		current_appliance.set_highlight(true)
