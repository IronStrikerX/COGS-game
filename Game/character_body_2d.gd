extends CharacterBody2D

const SPEED = 500.0

@export var player_id: int

@onready var selected_food_sprite: Sprite2D = %SelectedFood
@onready var player_sprite: Sprite2D = $PlayerSprite

var object: Area2D = null
var nearby_appliances: Array[StaticBody2D] = []
var current_appliance: StaticBody2D = null
var current_customer: Area2D = null

var selected_food: FoodResource = null

func _ready():
	match player_id:
		1: 
			player_sprite.texture = preload("uid://ua4v1jbf0f11")
		2:
			player_sprite.texture = preload("uid://5fnneva0kop")
			

func _physics_process(_delta: float) -> void:
	var prefix = "p%d_" % player_id
	var x_mov = Input.get_action_strength(prefix + "right") - Input.get_action_strength(prefix + "left")
	var y_mov = Input.get_action_strength(prefix + "down") - Input.get_action_strength(prefix + "up")
	var mov = Vector2(x_mov, y_mov)
	
	velocity = mov.normalized() * SPEED
	move_and_slide()
	if Input.is_action_just_pressed("debug"):
		print(current_customer)
		
	if Input.is_action_just_pressed(prefix + "action"):
		# Pick up food
		if not selected_food and object:
			selected_food = object.get_parent().food
			selected_food_sprite.texture = selected_food.texture
		
		# Drop food at station
		elif selected_food and current_appliance:
			if current_appliance.has_method("receive_food"):
				if current_appliance.receive_food(selected_food, player_id):
					#player will drop selected food only when 1. appliance is empty 2. player can cook with the 2 food
					selected_food = null
					selected_food_sprite.texture = null
			else:
				print("Station can't receive food")
		
		#pick up food at station
		elif not selected_food and current_appliance:
			if current_appliance.has_method("give_food"):
				var received = current_appliance.give_food(player_id)
				if received:
					selected_food = received
					selected_food_sprite.texture = selected_food.texture
					print("Picked up ", received.name, "from ", current_appliance.appliance_type)
		
		elif selected_food and current_customer:
			if current_customer.has_method("receive_food"):
				if current_customer.receive_food(selected_food):
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
