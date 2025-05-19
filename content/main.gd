extends Node

## Timeline for asking a general command.
@export var timeline_commands: DialogicTimeline

## Timeline declaring unit using a move.
@export var timeline_used_move: DialogicTimeline

enum {INPUT, EXECUTION, VICTORY, LOSE}
var current_state: int

var turn_number := 0
var pending_sequences: Array[Dictionary]
var current_sequence: Dictionary

func _ready() -> void:
	Dialogic.text_signal.connect(_dialogic_text_signal)
	change_state(INPUT)


func _dialogic_text_signal(event: String) -> void:
	match event:
		"execute_move":
			var target: BattleUnit = current_sequence["target"]
			target.take_damage(5)
			
			var target_bar = target.unit_bar
			await target_bar.hp_tween_finished
			
			pending_sequences.erase(current_sequence)
			if pending_sequences:
				execute_sequence()
			else:
				change_state(INPUT)


func _on_move_pressed() -> void:
	change_state(EXECUTION)


func change_state(val: int) -> void:
	current_state = val
	
	match current_state:
		INPUT:
			Dialogic.start_timeline(timeline_commands)
			%Commands.show()
		EXECUTION:
			pending_sequences = [
				{
					"user": $You,
					"target": $Foe
				},
				{
					"user": $Foe,
					"target": $You
				}
			]
			execute_sequence()


func execute_sequence() -> void:
	current_sequence = pending_sequences[0]
	Dialogic.start_timeline(timeline_used_move)
