extends Node2D
class_name BattleUnit

signal cur_hp_is_changed(cur_hp: int)

@export var unit_bar: PanelContainer

var max_hp := 10
var cur_hp := max_hp

func take_damage(dmg: int) -> void:
	cur_hp -= dmg
	cur_hp_is_changed.emit(cur_hp)
