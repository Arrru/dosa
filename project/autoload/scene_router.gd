extends Node

const BOOTSTRAP_SCENE := "res://project/scenes/bootstrap.tscn"
const INTRO_SCENE := "res://project/scenes/intro.tscn"
const TITLE_MENU_SCENE := "res://project/scenes/title_menu.tscn"
const SAVE_MENU_SCENE := "res://project/scenes/save_slots_menu.tscn"
const NAME_ENTRY_SCENE := "res://project/scenes/name_entry.tscn"
const GAME_SCENE := "res://project/scenes/game_root.tscn"


func to_intro() -> void:
	get_tree().call_deferred("change_scene_to_file", INTRO_SCENE)


func to_title_menu() -> void:
	get_tree().call_deferred("change_scene_to_file", TITLE_MENU_SCENE)


func to_save_slots(mode: String) -> void:
	GameState.pending_save_menu_mode = mode
	get_tree().call_deferred("change_scene_to_file", SAVE_MENU_SCENE)


func to_name_entry(slot_id: int) -> void:
	GameState.pending_slot_id = slot_id
	get_tree().call_deferred("change_scene_to_file", NAME_ENTRY_SCENE)


func to_game() -> void:
	get_tree().call_deferred("change_scene_to_file", GAME_SCENE)
