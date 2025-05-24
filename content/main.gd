extends Node

## A Node2D representing all units on your side.
@export var side_allies: Node2D

## A Node2D representing all units on your opponent's side.
@export var side_foes: Node2D

@export_group("Timelines")

## Timeline when the battle starts.
@export var timeline_start: DialogicTimeline

## Timeline when the opponent sends out their unit.
@export var timeline_foe_sends_out: DialogicTimeline

## Timeline when you send out your unit.
@export var timeline_you_send_out: DialogicTimeline

## Timeline for asking a general command.
@export var timeline_commands: DialogicTimeline

## Timeline declaring unit using a move.
@export var timeline_used_move: DialogicTimeline

## Timeline when the player wins.
@export var timeline_victory: DialogicTimeline

## Timeline when the player loses.
@export var timeline_defeat: DialogicTimeline

enum {INPUT, EXECUTION, START, VICTORY, LOSE}
var current_state: int

var turn_number := 0
var pending_sequences: Array[Dictionary]
var current_sequence: Dictionary

var you: DisplayedUnit
var foe: DisplayedUnit

const TRACK_SENDOUT := "send_out"

func _ready() -> void:
	you = side_allies.get_child(0)
	foe = side_foes.get_child(0)
	
	Dialogic.text_signal.connect(_dialogic_text_signal)
	change_state(START)


func _dialogic_text_signal(event: String) -> void:
	match event:
		"execute_move":
			var target: DisplayedUnit = current_sequence["target"]
			target.take_damage(current_sequence["power"])
			
			var target_bar = target.unit_bar
			await target_bar.hp_tween_finished
			
			if target.cur_unit.cur_hp <= 0:
				if target == foe:
					change_state(VICTORY)
				else:
					change_state(LOSE)
			
			next_in_sequence()
		
		"lead_out":
			pending_sequences = [
				{
					"timeline": timeline_foe_sends_out,
					"unit": side_foes.get_child(0),
					"switchin": side_foes.team[0]
				},
				{
					"timeline": timeline_you_send_out,
					"unit": side_allies.get_child(0),
					"switchin": side_allies.team[0]
				}
			]
			execute_sequence()
		
		"send_out_foe":
			send_out_anim(foe)
		
		"send_out_you":
			send_out_anim(you)


func _on_move_pressed(custom_pow: int = 5) -> void:
	pending_sequences = [
			{
				"user": you,
				"target": foe,
				"power": custom_pow,
				"timeline": timeline_used_move
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
					"power": 5,
					"timeline": timeline_used_move
				}
			)
			execute_sequence()
		START:
			Dialogic.start_timeline(timeline_start)
		VICTORY:
			Dialogic.start_timeline(timeline_victory)
		LOSE:
			Dialogic.start_timeline(timeline_defeat)


func execute_sequence() -> void:
	current_sequence = pending_sequences[0]
	Dialogic.start_timeline(current_sequence["timeline"])


func next_in_sequence() -> void:
	pending_sequences.erase(current_sequence)
	if pending_sequences:
		execute_sequence()
	else:
		change_state(INPUT)


func send_out_anim(unit: DisplayedUnit) -> void:
	current_sequence["unit"].set_unit(current_sequence["switchin"])
	var anim_player: AnimationPlayer = unit.get_node("AnimationPlayer")
	anim_player.play(TRACK_SENDOUT)
	
	if await anim_player.animation_finished == TRACK_SENDOUT:
		next_in_sequence()
