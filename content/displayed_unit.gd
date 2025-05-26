extends Node2D
class_name DisplayedUnit

## A unit currently shown on-screen.

signal cur_hp_is_changed(cur_hp: int)

@export var unit_bar: PanelContainer

var team: Array[BattleUnit]

var cur_unit: BattleUnit

func _ready() -> void:
	team = get_parent().team


func get_unit_name() -> String:
	return cur_unit.name


func is_out_of_hp() -> bool:
	return cur_unit.cur_hp <= 0


## Plays a unit animation. Returns true
## when the animation finishes playing the given track.
func play_anim(track: String) -> bool:
	$AnimationPlayer.play(track)
	
	return await $AnimationPlayer.animation_finished == track


func set_unit(val: BattleUnit) -> void:
	cur_unit = val
	$Sprite2D.set_texture(val.sprite)
	unit_bar.set_unit(val)


func take_damage(dmg: int) -> void:
	cur_unit.cur_hp -= dmg
	cur_hp_is_changed.emit(cur_unit.cur_hp)
