extends Node

## Emitted at the end of turn, when your unit is
## knocked out and you still have avaiable units
## to choose from to swap in and continue the
## battle.
signal user_needs_reinforcement

enum {INPUT, EXECUTION, START, VICTORY, LOSE}

## A Node2D representing all units on your side.
@export var side_allies: Node2D

## A Node2D representing all units on your opponent's side.
@export var side_foes: Node2D

## A VBoxContainer displaying your team.
@export var team: VBoxContainer

@export var textboxes: Array[DialogicLayoutLayer]

@export var swapin_btn: Button

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

## Timeline when you withdraw your unit.
@export var timeline_you_recall: DialogicTimeline

## Timeline when your opponent withdraw their unit.
@export var timeline_foe_recall: DialogicTimeline

## Timeline when a unit's HP reaches zero.
@export var timeline_koed: DialogicTimeline

## Timeline when the player wins.
@export var timeline_victory: DialogicTimeline

## Timeline when the player loses.
@export var timeline_defeat: DialogicTimeline

var current_state: int

var current_textbox := 0

var turn_number := 0
var pending_sequences: Array[Dictionary]
var current_sequence: Dictionary

var you: DisplayedUnit
var foe: DisplayedUnit

func _ready() -> void:
	you = side_allies.get_child(0)
	foe = side_foes.get_child(0)
	
	Dialogic.signal_event.connect(_dialogic_event_signal)
	Dialogic.text_signal.connect(_dialogic_text_signal)
	change_state(START)


func _dialogic_event_signal(event: Variant) -> void:
	match event:
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


func _dialogic_text_signal(event: String) -> void:
	match event:
		"execute_move":
			var target: DisplayedUnit = current_sequence["target"]
			target.take_damage(current_sequence["power"])
			
			var target_bar = target.unit_bar
			await target_bar.hp_tween_finished
			
			if target.is_out_of_hp():
				remove_user_from_sequence(target)
				if await target.play_anim("knocked_out"):
					target.unit_bar.hide()
					Dialogic.start_timeline(timeline_koed)
				
				if await Dialogic.signal_event == "ko":
					if target.get_parent().has_available_units():
						var target_side: UnitSide = target.get_parent()
						pending_sequences.append({
							"timeline": timeline_foe_sends_out if target_side.get_index() else timeline_you_send_out,
							"unit": target,
							"switchin": null})
						next_in_sequence()
					else:
						if target == foe:
							change_state(VICTORY)
						else:
							change_state(LOSE)
			
			else:
				next_in_sequence()
		
		"recall":
			recall_anim(current_sequence["unit"])
		
		"send_out_foe":
			send_out_anim(foe)
		
		"send_out_you":
			send_out_anim(you)


func _on_move_pressed(custom_pow: int = 10) -> void:
	pending_sequences = [
			{
				"user": you,
				"target": foe,
				"move_name": "Horn Drill" if custom_pow < 6 else "Tackle",
				"power": custom_pow,
				"timeline": timeline_used_move
			}
		]
	change_state(EXECUTION)


func _on_switchin_pressed() -> void:
	if current_state == INPUT:
		pending_sequences = [
				{
					"unit": side_allies.get_child(0),
					"switchout": you,
					"switchin": team.selected_unit,
					"timeline": timeline_you_recall
				}
			]
		change_state(EXECUTION)


func change_state(val: int) -> void:
	current_state = val
	
	match current_state:
		INPUT:
			Dialogic.VAR.Battle.User = side_allies.get_child(0).get_unit_name()
			Dialogic.start_timeline(timeline_commands)
			%Commands.show()
		EXECUTION:
			pending_sequences.append(
				{
					"user": foe,
					"target": you,
					"move_name": "Tackle",
					"power": 10,
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


func change_textbox(i: int) -> void:
	textboxes[current_textbox].disabled = true
	current_textbox = i
	textboxes[current_textbox].disabled = false


func execute_sequence() -> void:
	current_sequence = pending_sequences[0]
	
	if "user" in current_sequence:
		Dialogic.VAR.Battle.User = current_sequence["user"].get_unit_name()
		Dialogic.VAR.Battle.Move = current_sequence["move_name"]
		Dialogic.VAR.Battle.Target = current_sequence["target"].get_unit_name()
	elif "switchout" in current_sequence:
		Dialogic.VAR.Battle.User = current_sequence["switchout"].get_unit_name()
	elif "switchin" in current_sequence:
		if current_sequence["switchin"] == null:
			var unit_side: UnitSide = current_sequence["unit"].get_parent()
			if unit_side.get_index() == 0:
				user_needs_reinforcement.emit()
				await swapin_btn.approved_pressed
				current_sequence["switchin"] = team.selected_unit
			else:
				current_sequence["switchin"] = unit_side.get_next_available()
		
		Dialogic.VAR.Battle.User = current_sequence["switchin"].name
	
	Dialogic.start_timeline(current_sequence["timeline"])


func next_in_sequence() -> void:
	pending_sequences.erase(current_sequence)
	if pending_sequences:
		execute_sequence()
	else:
		change_state(INPUT)


func recall_anim(unit: DisplayedUnit) -> void:
	if await unit.play_anim("recall"):
		Dialogic.VAR.Battle.User = current_sequence["switchin"].name
		Dialogic.start_timeline(timeline_you_send_out)


func remove_user_from_sequence(user: DisplayedUnit) -> void:
	for sequence: Dictionary in pending_sequences:
		if "user" in sequence and sequence["user"] == user:
			pending_sequences.erase(sequence)


func send_out_anim(unit: DisplayedUnit) -> void:
	current_sequence["unit"].set_unit(current_sequence["switchin"])
	
	if await unit.play_anim("send_out"):
		next_in_sequence()
