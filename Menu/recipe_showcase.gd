extends HBoxContainer

enum ApplianceType {OVEN, STOVE, DEEP_FRY_STATION, ASSEMBLY_STATION, COUNTERTOP, TRASH_BIN}

@onready var requirement_1: TextureRect = $Requirement1
@onready var requirement_2: TextureRect = $Requirement2
@onready var item: TextureRect = $Item

@onready var requirement_1_label: Label = $Requirement1/Requirement1Label
@onready var requirement_2_label: Label = $Requirement2/Requirement2Label
@onready var item_label: Label = $Item/ItemLabel

func show_processable_recipe(req: FoodResource, appliance: int, product: FoodResource):
	var str: String
	match appliance:
		ApplianceType.OVEN:
			str = "Oven"
		ApplianceType.STOVE:
			str = "Stove"
		ApplianceType.DEEP_FRY_STATION:
			str = "Deep Fry Station"
		ApplianceType.ASSEMBLY_STATION:
			str = "Assembly Station"
		ApplianceType.COUNTERTOP:
			str = "Countertop"
		ApplianceType.TRASH_BIN:
			str = "Trash Bin"
		
	requirement_1.texture = req.texture
	requirement_2.texture = null
	item.texture = product.texture
	
	requirement_1_label.text = req.name
	requirement_2_label.text = str
	item_label.text = product.name

func show_cookable_recipe(req: FoodResource, req2: FoodResource, product: FoodResource):
	requirement_1.texture = req.texture
	requirement_2.texture = req2.texture
	item.texture = product.texture
	
	requirement_1_label.text = req.name
	requirement_2_label.text = req2.name
	item_label.text = product.name
