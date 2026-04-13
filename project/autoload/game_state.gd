extends Node

signal state_changed
signal collection_changed

const PHASES := ["낮", "밤", "자유시간"]

var pending_save_menu_mode := "new"
var pending_slot_id := 1

var current_slot_id := 0
var player_name := ""
var day_number := 1
var phase_index := 0
var actions_remaining := 2
var current_view_id := "north"

var affection := {"catalog_warden": 0}
var skills := {"research": 0, "empathy": 0, "nerve": 0}
var unlocked_codex_ids: Array[String] = []
var unlocked_manual_ids: Array[String] = []
var seen_dialogue_ids: Array[String] = []
var flags := {}


func start_new_game(slot_id: int, name: String) -> void:
	current_slot_id = slot_id
	player_name = name.strip_edges()
	day_number = 1
	phase_index = 0
	actions_remaining = 2
	current_view_id = "north"
	affection = {"catalog_warden": 0}
	skills = {"research": 0, "empathy": 0, "nerve": 0}
	unlocked_codex_ids = []
	unlocked_manual_ids = []
	seen_dialogue_ids = []
	flags = {
		"intro_pending": true,
		"met_warden": false,
		"ending_stub_ready": false,
		"ending_stub_seen": false,
		"second_run_unlocked": false
	}
	emit_signal("state_changed")
	emit_signal("collection_changed")


func get_phase_name() -> String:
	return PHASES[phase_index]


func spend_actions(amount: int = 1) -> void:
	var remaining := amount
	while remaining > 0:
		actions_remaining -= 1
		remaining -= 1
		if actions_remaining <= 0:
			advance_phase()
	emit_signal("state_changed")


func advance_phase() -> void:
	phase_index = (phase_index + 1) % PHASES.size()
	if phase_index == 0:
		day_number += 1
	actions_remaining = 2


func mark_dialogue_seen(dialogue_id: String) -> void:
	if not seen_dialogue_ids.has(dialogue_id):
		seen_dialogue_ids.append(dialogue_id)


func unlock_codex(entry_id: String) -> void:
	if not unlocked_codex_ids.has(entry_id):
		unlocked_codex_ids.append(entry_id)
		emit_signal("collection_changed")


func unlock_manual(entry_id: String) -> void:
	if not unlocked_manual_ids.has(entry_id):
		unlocked_manual_ids.append(entry_id)
		emit_signal("collection_changed")


func apply_effects(effects: Dictionary) -> void:
	if effects.has("affection"):
		for key in effects["affection"].keys():
			affection[key] = int(affection.get(key, 0)) + int(effects["affection"][key])
	if effects.has("skills"):
		for key in effects["skills"].keys():
			skills[key] = int(skills.get(key, 0)) + int(effects["skills"][key])
	if effects.has("unlock_codex"):
		for entry_id in effects["unlock_codex"]:
			unlock_codex(String(entry_id))
	if effects.has("unlock_manual"):
		for entry_id in effects["unlock_manual"]:
			unlock_manual(String(entry_id))
	if effects.has("flags"):
		for key in effects["flags"].keys():
			flags[String(key)] = effects["flags"][key]
	if effects.has("goto_view"):
		current_view_id = String(effects["goto_view"])
	if effects.has("spend_time"):
		spend_actions(int(effects["spend_time"]))
	else:
		emit_signal("state_changed")


func to_dict() -> Dictionary:
	return {
		"current_slot_id": current_slot_id,
		"player_name": player_name,
		"day_number": day_number,
		"phase_index": phase_index,
		"actions_remaining": actions_remaining,
		"current_view_id": current_view_id,
		"affection": affection.duplicate(true),
		"skills": skills.duplicate(true),
		"unlocked_codex_ids": unlocked_codex_ids.duplicate(),
		"unlocked_manual_ids": unlocked_manual_ids.duplicate(),
		"seen_dialogue_ids": seen_dialogue_ids.duplicate(),
		"flags": flags.duplicate(true)
	}


func load_from_dict(data: Dictionary) -> void:
	current_slot_id = int(data.get("current_slot_id", 0))
	player_name = String(data.get("player_name", ""))
	day_number = int(data.get("day_number", 1))
	phase_index = int(data.get("phase_index", 0))
	actions_remaining = int(data.get("actions_remaining", 2))
	current_view_id = String(data.get("current_view_id", "north"))
	affection = data.get("affection", {"catalog_warden": 0}).duplicate(true)
	skills = data.get("skills", {"research": 0, "empathy": 0, "nerve": 0}).duplicate(true)
	unlocked_codex_ids = _string_array_from_variant(data.get("unlocked_codex_ids", []))
	unlocked_manual_ids = _string_array_from_variant(data.get("unlocked_manual_ids", []))
	seen_dialogue_ids = _string_array_from_variant(data.get("seen_dialogue_ids", []))
	flags = data.get("flags", {}).duplicate(true)
	emit_signal("state_changed")
	emit_signal("collection_changed")


func _string_array_from_variant(values: Variant) -> Array[String]:
	var result: Array[String] = []
	for value in Array(values):
		result.append(String(value))
	return result
