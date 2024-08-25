extends Control


@export var faction_types = ["Sun Sage", "Valkaryan", "Untethered", "Quantum Swarm"]
var selected_faction = ""

# Signal to notify when a faction is selected
signal faction_selected(selected_faction)

func _ready():
	pass

func _on_faction_selected(faction_id):
	selected_faction = faction_types[faction_id]
	print("Selected Faction: ", selected_faction)
	emit_signal("faction_selected", faction_id)
