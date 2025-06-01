extends VBoxContainer

@export var side: UnitSide

func _ready() -> void:
	var team: Array[BattleUnit] = side.team
	
	for i in team.size():
		var unit: BattleUnit = team[i]
		var option_panel: PanelContainer = get_child(i)
		
		option_panel.set_unit(unit)
		option_panel.show()
