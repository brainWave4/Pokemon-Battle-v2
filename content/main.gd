extends Node

## Timeline for asking a general command.
@export var timeline_commands: DialogicTimeline

## Timeline declaring unit using a move.
@export var timeline_used_move: DialogicTimeline

func _ready() -> void:
	Dialogic.start_timeline(timeline_commands)


func _on_move_pressed() -> void:
	Dialogic.start_timeline(timeline_used_move)
