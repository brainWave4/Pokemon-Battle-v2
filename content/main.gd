extends Node

## Timeline for asking a general command.
@export var timeline_commands: DialogicTimeline

## Timeline declaring unit using a move.
@export var timeline_used_move: DialogicTimeline

func _ready() -> void:
	Dialogic.text_signal.connect(_dialogic_text_signal)
	Dialogic.start_timeline(timeline_commands)


func _dialogic_text_signal(event: String) -> void:
	match event:
		"execute_move":
			print("Tackle")


func _on_move_pressed() -> void:
	Dialogic.start_timeline(timeline_used_move)
