class_name CookingRecipe
extends Resource

enum ApplianceType {OVEN, STOVE, DEEP_FRY_STATION, ASSEMBLY_STATION, COUNTERTOP, TRASH_BIN}

@export var item: FoodResource
@export var requirement: Array[FoodResource]
@export var appliance: ApplianceType
@export var time_required: float
