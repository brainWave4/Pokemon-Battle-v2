extends Node2D
class_name UnitSide

## A group of units taking part of this battle.
@export var team: Array[BattleUnit]

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
