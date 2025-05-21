extends Node

## A Node2D representing all units on your side.
@export var side_allies: Node2D

## A Node2D representing all units on your opponent's side.
@export var side_foes: Node2D

@export_group("Timelines")

## Timeline for asking a general command.
@export var timeline_commands: DialogicTimeline

## Timeline declaring unit using a move.
@export var timeline_used_move: DialogicTimeline

## Timeline for when the player wins.
@export var timeline_victory: DialogicTimeline

## Timeline for when the player loses.
@export var timeline_defeat: DialogicTimeline

enum {INPUT, EXECUTION, VICTORY, LOSE}
var current_state: int

var turn_number := 0
var pending_sequences: Array[Dictionary]
var current_sequence: Dictionary

var you: Node2D
var foe: Node2D

func _ready() -> void:
	you = side_allies.get_child(0)
	foe = side_foes.get_child(0)
	
	Dialogic.text_signal.connect(_dialogic_text_signal)
	change_state(INPUT)


func _dialogic_text_signal(event: String) -> void:
	match event:
		"execute_move":
			var target: BattleUnit = current_sequence["target"]
			target.take_damage(current_sequence["power"])
			
			var target_bar = target.unit_bar
			await target_bar.hp_tween_finished
			
			if target.cur_hp <= 0:
				if target == foe:
					change_state(VICTORY)
				else:
					change_state(LOSE)
			
			pending_sequences.erase(current_sequence)
			if pending_sequences:
				execute_sequence()
			else:
				change_state(INPUT)


func _on_move_pressed(custom_pow: int = 5) -> void:
	pending_sequences = [
			{
				"user": you,
				"target": foe,
				"power": custom_pow
			}
		]
	change_state(EXECUTION)


func change_state(val: int) -> void:
	current_state = val
	
	match current_state:
		INPUT:
			Dialogic.start_timeline(timeline_commands)
			%Commands.show()
		EXECUTION:
			pending_sequences.append(
				{
					"user": foe,
					"target": you,
					"power": 5
				}
			)
			execute_sequence()
		VICTORY:
			Dialogic.start_timeline(timeline_victory)
		LOSE:
			Dialogic.start_timeline(timeline_defeat)


func execute_sequence() -> void:
	current_sequence = pending_sequences[0]
	Dialogic.start_timeline(timeline_used_move)
