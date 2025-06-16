extends Node2D
class_name UnitSide

## A group of units taking part of this battle.
@export var team: Array[BattleUnit]

func _ready() -> void:
	for bu: BattleUnit in team:
		bu.cur_hp = bu.max_hp


func get_next_available() -> BattleUnit:
	for bu: BattleUnit in team:
		if bu.cur_hp:
			return bu
			
	return team[0]


## Checks whether there are any remaining units
## that are able to battle.
func has_available_units() -> bool:
	for bu: BattleUnit in team:
		if bu.cur_hp:
			return true
	
	return false


func has_unit_out_in_battle(unit: BattleUnit) -> bool:
	for child: DisplayedUnit in get_children():
		if child.cur_unit == unit:
			return true
	
	return false
