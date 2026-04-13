extends Node

const SLOT_COUNT := 3


func is_web_environment() -> bool:
	return OS.has_feature("web")


func get_persistence_warning() -> String:
	if not is_web_environment():
		return ""
	return "웹 버전의 저장은 브라우저 저장소를 사용합니다. 사생활 보호 모드, 저장공간 차단, 사이트 데이터 삭제 시 세이브가 유지되지 않을 수 있습니다."


func get_slot_path(slot_id: int) -> String:
	return "user://slot_%d.json" % slot_id


func save_current_game() -> bool:
	if GameState.current_slot_id <= 0:
		return false
	return save_slot(GameState.current_slot_id, GameState.to_dict())


func save_slot(slot_id: int, data: Dictionary) -> bool:
	var file := FileAccess.open(get_slot_path(slot_id), FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	return true


func load_slot(slot_id: int) -> bool:
	if not FileAccess.file_exists(get_slot_path(slot_id)):
		return false
	var file := FileAccess.open(get_slot_path(slot_id), FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	GameState.load_from_dict(parsed)
	return true


func get_slot_summaries() -> Array:
	var summaries: Array = []
	for slot_id in range(1, SLOT_COUNT + 1):
		var parsed := _read_slot_data(slot_id)
		if not parsed.is_empty():
			summaries.append(_build_summary(slot_id, parsed, true))
			continue
		summaries.append(_build_summary(slot_id, {}, false))
	return summaries


func get_progress_overview() -> Dictionary:
	var used_slots := 0
	var best_day := 0
	var highest_affection := 0
	var unique_codex := {}
	var unique_manual := {}
	var ending_seen := false
	var second_run_unlocked := false
	var slot_details: Array = []
	for slot_id in range(1, SLOT_COUNT + 1):
		var parsed := _read_slot_data(slot_id)
		if parsed.is_empty():
			continue
		used_slots += 1
		best_day = max(best_day, int(parsed.get("day_number", 1)))
		highest_affection = max(highest_affection, int(parsed.get("affection", {}).get("catalog_warden", 0)))
		for entry_id in Array(parsed.get("unlocked_codex_ids", [])):
			unique_codex[String(entry_id)] = true
		for entry_id in Array(parsed.get("unlocked_manual_ids", [])):
			unique_manual[String(entry_id)] = true
		var flags: Dictionary = parsed.get("flags", {})
		ending_seen = ending_seen or bool(flags.get("ending_stub_seen", false))
		second_run_unlocked = second_run_unlocked or bool(flags.get("second_run_unlocked", false))
		slot_details.append({
			"slot_id": slot_id,
			"player_name": String(parsed.get("player_name", "")),
			"day_number": int(parsed.get("day_number", 1)),
			"phase_name": GameState.PHASES[int(parsed.get("phase_index", 0))],
			"codex_count": Array(parsed.get("unlocked_codex_ids", [])).size(),
			"manual_count": Array(parsed.get("unlocked_manual_ids", [])).size()
		})
	return {
		"used_slots": used_slots,
		"best_day": best_day,
		"highest_affection": highest_affection,
		"unique_codex_count": unique_codex.size(),
		"unique_manual_count": unique_manual.size(),
		"ending_seen": ending_seen,
		"second_run_unlocked": second_run_unlocked,
		"slot_details": slot_details
	}


func _build_summary(slot_id: int, data: Dictionary, has_data: bool) -> Dictionary:
	return {
		"slot_id": slot_id,
		"has_data": has_data,
		"player_name": String(data.get("player_name", "빈 슬롯")),
		"day_number": int(data.get("day_number", 1)),
		"phase_name": GameState.PHASES[int(data.get("phase_index", 0))] if has_data else "미사용",
		"affection": int(data.get("affection", {}).get("catalog_warden", 0)) if has_data else 0
	}


func _read_slot_data(slot_id: int) -> Dictionary:
	if not FileAccess.file_exists(get_slot_path(slot_id)):
		return {}
	var file := FileAccess.open(get_slot_path(slot_id), FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
