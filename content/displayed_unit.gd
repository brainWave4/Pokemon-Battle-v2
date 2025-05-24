extends Node2D
class_name DisplayedUnit

## A unit currently shown on-screen.

signal cur_hp_is_changed(cur_hp: int)

@export var unit_bar: PanelContainer

var team: Array[BattleUnit]

var cur_unit: BattleUnit

func _ready() -> void:
	team = get_parent().team


func set_unit(val: BattleUnit) -> void:
	cur_unit = val
	$Sprite2D.set_texture(val.sprite)
	unit_bar.set_unit(val)


func take_damage(dmg: int) -> void:
	cur_unit.cur_hp -= dmg
	cur_hp_is_changed.emit(cur_unit.cur_hp)
