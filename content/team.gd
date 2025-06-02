extends VBoxContainer

@export var side: UnitSide

var selected_unit: BattleUnit

func _ready() -> void:
	var team: Array[BattleUnit] = side.team
	
	for i in team.size():
		var unit: BattleUnit = team[i]
		var option_panel: SwitchOption = get_child(i)
		
		option_panel.set_unit(unit)
		option_panel.unit_is_selected.connect(func (base_unit: BattleUnit) -> void:
			selected_unit = base_unit
		)
		option_panel.show()
