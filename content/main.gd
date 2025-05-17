extends Node

@export var timeline_commands: DialogicTimeline

func _ready() -> void:
	Dialogic.start_timeline(timeline_commands)
