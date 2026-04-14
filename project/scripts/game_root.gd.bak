extends Control

#const UI_THEME:= "res://project/assets/fonts/ui_theme.tres"

var background_rect: ColorRect
var floor_rect: ColorRect
var accent_rect: ColorRect
var hud_label: Label
var stats_label: Label
var notice_label: Label
var hotspot_layer: Control
var view_label: Label
var scene_hint_label: Label
var dialogue_overlay: PanelContainer
var dialogue_name_label: Label
var dialogue_text_label: RichTextLabel
var choice_container: VBoxContainer
var collection_overlay: PanelContainer
var collection_title: Label
var collection_mode_label: Label
var collection_list: ItemList
var collection_detail: RichTextLabel
var collection_empty_label: Label
var current_collection_entries: Array = []
var last_day_number := -1
var last_phase_index := -1


func _ready() -> void:
	#theme = load(UI_THEME)
	_build_ui()
	if not GameState.state_changed.is_connected(_refresh_ui):
		GameState.state_changed.connect(_refresh_ui)
	if not GameState.collection_changed.is_connected(_refresh_ui):
		GameState.collection_changed.connect(_refresh_ui)
	_refresh_ui()
	if GameState.flags.get("intro_pending", false):
		GameState.flags["intro_pending"] = false
		_show_dialogue("arrival_intro")
	last_day_number = GameState.day_number
	last_phase_index = GameState.phase_index


func _build_ui() -> void:
	var base := ColorRect.new()
	base.anchor_right = 1.0
	base.anchor_bottom = 1.0
	base.color = Color("141117")
	add_child(base)

	background_rect = ColorRect.new()
	background_rect.position = Vector2(120, 90)
	background_rect.size = Vector2(1040, 520)
	add_child(background_rect)

	floor_rect = ColorRect.new()
	floor_rect.position = Vector2(120, 470)
	floor_rect.size = Vector2(1040, 140)
	add_child(floor_rect)

	accent_rect = ColorRect.new()
	accent_rect.position = Vector2(470, 210)
	accent_rect.size = Vector2(340, 180)
	add_child(accent_rect)

	var frame := Panel.new()
	frame.position = Vector2(108, 78)
	frame.size = Vector2(1064, 544)
	add_child(frame)

	hotspot_layer = Control.new()
	hotspot_layer.position = background_rect.position
	hotspot_layer.size = background_rect.size
	add_child(hotspot_layer)

	view_label = Label.new()
	view_label.position = Vector2(130, 36)
	view_label.add_theme_font_size_override("font_size", 28)
	add_child(view_label)

	scene_hint_label = Label.new()
	scene_hint_label.position = Vector2(150, 120)
	scene_hint_label.size = Vector2(980, 40)
	scene_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_hint_label.add_theme_font_size_override("font_size", 24)
	add_child(scene_hint_label)

	hud_label = Label.new()
	hud_label.position = Vector2(700, 36)
	hud_label.size = Vector2(460, 28)
	hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(hud_label)

	stats_label = Label.new()
	stats_label.position = Vector2(120, 622)
	stats_label.size = Vector2(620, 80)
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(stats_label)

	notice_label = Label.new()
	notice_label.position = Vector2(760, 622)
	notice_label.size = Vector2(400, 80)
	notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice_label.text = SaveManager.get_persistence_warning() if SaveManager.is_web_environment() else "수상한 부분을 조사하여 이벤트를 진행하세요."
	add_child(notice_label)

	_add_nav_button("← 좌", Vector2(24, 288), _on_go_left)
	_add_nav_button("우 →", Vector2(1180, 288), _on_go_right)
	_add_nav_button("↓ 하", Vector2(600, 28), _on_go_down)

	var menu_bar := HBoxContainer.new()
	menu_bar.position = Vector2(760, 650)
	menu_bar.size = Vector2(400, 40)
	menu_bar.add_theme_constant_override("separation", 8)
	add_child(menu_bar)

	_add_menu_bar_button(menu_bar, "도감", func() -> void: _show_collection("도감", ContentDB.get_codex_entries(GameState.unlocked_codex_ids)))
	_add_menu_bar_button(menu_bar, "메뉴얼", func() -> void: _show_collection("메뉴얼", ContentDB.get_manual_entries(GameState.unlocked_manual_ids)))
	_add_menu_bar_button(menu_bar, "저장", _on_save_pressed)
	_add_menu_bar_button(menu_bar, "휴식", _on_rest_pressed)
	_add_menu_bar_button(menu_bar, "타이틀", _on_title_pressed)

	_build_dialogue_overlay()
	_build_collection_overlay()


func _add_nav_button(text: String, position: Vector2, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(72, 44)
	button.pressed.connect(callback)
	add_child(button)


func _add_menu_bar_button(menu_bar: HBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(72, 36)
	button.pressed.connect(callback)
	menu_bar.add_child(button)


func _build_dialogue_overlay() -> void:
	dialogue_overlay = PanelContainer.new()
	dialogue_overlay.position = Vector2(180, 120)
	dialogue_overlay.size = Vector2(920, 500)
	dialogue_overlay.visible = false
	add_child(dialogue_overlay)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 24
	margin.offset_top = 24
	margin.offset_right = -24
	margin.offset_bottom = -24
	dialogue_overlay.add_child(margin)

	var layout := VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	dialogue_name_label = Label.new()
	dialogue_name_label.add_theme_font_size_override("font_size", 28)
	layout.add_child(dialogue_name_label)

	dialogue_text_label = RichTextLabel.new()
	dialogue_text_label.fit_content = false
	dialogue_text_label.scroll_active = true
	dialogue_text_label.custom_minimum_size = Vector2(0, 220)
	layout.add_child(dialogue_text_label)

	choice_container = VBoxContainer.new()
	choice_container.add_theme_constant_override("separation", 8)
	layout.add_child(choice_container)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.pressed.connect(func() -> void: dialogue_overlay.visible = false)
	layout.add_child(close_button)


func _build_collection_overlay() -> void:
	collection_overlay = PanelContainer.new()
	collection_overlay.position = Vector2(240, 120)
	collection_overlay.size = Vector2(800, 480)
	collection_overlay.visible = false
	add_child(collection_overlay)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 24
	margin.offset_top = 24
	margin.offset_right = -24
	margin.offset_bottom = -24
	collection_overlay.add_child(margin)

	var layout := VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	collection_title = Label.new()
	collection_title.add_theme_font_size_override("font_size", 26)
	layout.add_child(collection_title)

	collection_mode_label = Label.new()
	collection_mode_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(collection_mode_label)

	var content_row := HBoxContainer.new()
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 16)
	layout.add_child(content_row)

	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(220, 320)
	content_row.add_child(list_panel)

	var list_margin := MarginContainer.new()
	list_margin.anchor_right = 1.0
	list_margin.anchor_bottom = 1.0
	list_margin.offset_left = 10
	list_margin.offset_top = 10
	list_margin.offset_right = -10
	list_margin.offset_bottom = -10
	list_panel.add_child(list_margin)

	collection_list = ItemList.new()
	collection_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	collection_list.item_selected.connect(_on_collection_item_selected)
	list_margin.add_child(collection_list)

	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.anchor_right = 1.0
	detail_margin.anchor_bottom = 1.0
	detail_margin.offset_left = 12
	detail_margin.offset_top = 12
	detail_margin.offset_right = -12
	detail_margin.offset_bottom = -12
	detail_panel.add_child(detail_margin)

	var detail_layout := VBoxContainer.new()
	detail_layout.anchor_right = 1.0
	detail_layout.anchor_bottom = 1.0
	detail_margin.add_child(detail_layout)

	collection_empty_label = Label.new()
	collection_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	collection_empty_label.text = "아직 기록된 페이지가 없습니다."
	detail_layout.add_child(collection_empty_label)

	collection_detail = RichTextLabel.new()
	collection_detail.bbcode_enabled = true
	collection_detail.scroll_active = true
	collection_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	collection_detail.custom_minimum_size = Vector2(0, 300)
	detail_layout.add_child(collection_detail)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(0, 40)
	close_button.pressed.connect(func() -> void: collection_overlay.visible = false)
	layout.add_child(close_button)


func _refresh_ui() -> void:
	var view := ContentDB.get_view(GameState.current_view_id)
	view_label.text = "%s | %s 시점" % [GameState.player_name, view["title"]]
	hud_label.text = "%d일차 %s | 행동 %d회 남음" % [GameState.day_number, GameState.get_phase_name(), GameState.actions_remaining]
	stats_label.text = "호감도 %d | 괴담 연구 %d / 공감도 %d / 정신력 %d | 도감 %d개 | 메뉴얼 %d개" % [
		int(GameState.affection.get("catalog_warden", 0)),
		int(GameState.skills.get("research", 0)),
		int(GameState.skills.get("empathy", 0)),
		int(GameState.skills.get("nerve", 0)),
		GameState.unlocked_codex_ids.size(),
		GameState.unlocked_manual_ids.size()
	]
	background_rect.color = view["background_color"]
	floor_rect.color = view["floor_color"]
	accent_rect.color = view["accent_color"]
	scene_hint_label.text = "%s | 수상한 지점을 조사하세요" % view["title"]
	_refresh_hotspots(view)


func _refresh_hotspots(view: Dictionary) -> void:
	for child in hotspot_layer.get_children():
		child.queue_free()
	for hotspot_id in view["hotspots"]:
		var data := ContentDB.get_hotspot(String(hotspot_id))
		var button := Button.new()
		button.text = data["label"]
		button.position = data["rect"].position
		button.size = data["rect"].size
		button.modulate = Color(1, 1, 1, 0.78)
		button.pressed.connect(_on_hotspot_pressed.bind(String(hotspot_id)))
		hotspot_layer.add_child(button)


func _on_go_left() -> void:
	_change_view("left")


func _on_go_right() -> void:
	_change_view("right")


func _on_go_down() -> void:
	_change_view("down")


func _change_view(direction: String) -> void:
	if _is_overlay_open():
		return
	var view := ContentDB.get_view(GameState.current_view_id)
	if view.has(direction):
		GameState.current_view_id = String(view[direction])
		GameState.emit_signal("state_changed")


func _on_hotspot_pressed(hotspot_id: String) -> void:
	if _is_overlay_open():
		return
	var hotspot := ContentDB.get_hotspot(hotspot_id)
	notice_label.text = "%s 조사 중" % hotspot["label"]
	if hotspot.has("dialogue_id"):
		_show_dialogue(String(hotspot["dialogue_id"]))


func _show_dialogue(dialogue_id: String) -> void:
	var data := ContentDB.get_dialogue(dialogue_id)
	if data.is_empty():
		return
	GameState.mark_dialogue_seen(dialogue_id)
	dialogue_overlay.visible = true
	dialogue_name_label.text = String(data.get("speaker", ""))
	dialogue_text_label.text = String(data.get("text", ""))
	for child in choice_container.get_children():
		child.queue_free()
	for choice in data.get("choices", []):
		var button := Button.new()
		button.text = String(choice.get("text", "계속"))
		button.custom_minimum_size = Vector2(0, 54)
		button.pressed.connect(_on_choice_pressed.bind(choice))
		choice_container.add_child(button)
	if choice_container.get_child_count() == 0:
		var close_button := Button.new()
		close_button.text = "확인"
		close_button.custom_minimum_size = Vector2(0, 48)
		close_button.pressed.connect(func() -> void: dialogue_overlay.visible = false)
		choice_container.add_child(close_button)


func _on_choice_pressed(choice: Dictionary) -> void:
	var previous_day := GameState.day_number
	var previous_phase := GameState.phase_index
	GameState.apply_effects(choice.get("effects", {}))
	var next_id := String(choice.get("next", ""))
	if not next_id.is_empty():
		_show_dialogue(next_id)
	else:
		dialogue_overlay.visible = false
	_refresh_ui()
	_update_progress_notice(previous_day, previous_phase)
	_check_ending_stub()


func _show_collection(title: String, entries: Array) -> void:
	if dialogue_overlay.visible:
		return
	collection_overlay.visible = true
	collection_title.text = title
	collection_mode_label.text = _get_collection_mode_text(title)
	current_collection_entries = entries.duplicate(true)
	collection_list.clear()
	if entries.is_empty():
		collection_empty_label.visible = true
		collection_detail.visible = false
		collection_empty_label.text = "%s이 아직 비어 있습니다." % title
		return
	collection_empty_label.visible = false
	collection_detail.visible = true
	for entry in entries:
		var label := String(entry.get("page_label", "기록")) + " | " + String(entry.get("title", ""))
		collection_list.add_item(label)
	collection_list.select(0)
	_render_collection_detail(0)


func _on_save_pressed() -> void:
	if _is_overlay_open():
		return
	if SaveManager.save_current_game():
		notice_label.text = "Slot %d에 저장했습니다." % GameState.current_slot_id
	else:
		notice_label.text = "저장에 실패했습니다. 브라우저 저장소 또는 파일 쓰기 권한을 확인하세요."


func _on_rest_pressed() -> void:
	if _is_overlay_open():
		return
	var previous_day := GameState.day_number
	var previous_phase := GameState.phase_index
	GameState.spend_actions(GameState.actions_remaining)
	notice_label.text = "짧게 쉰 뒤 시간이 흘렀습니다."
	_update_progress_notice(previous_day, previous_phase)
	_check_ending_stub()


func _on_title_pressed() -> void:
	if _is_overlay_open():
		return
	SaveManager.save_current_game()
	SceneRouter.to_title_menu()


func _is_overlay_open() -> bool:
	return dialogue_overlay.visible or collection_overlay.visible


func _update_progress_notice(previous_day: int, previous_phase: int) -> void:
	if previous_day != GameState.day_number:
		notice_label.text = "%d일차가 시작되었습니다.\n오늘도 규칙을 지키며 버텨야 합니다." % GameState.day_number
	elif previous_phase != GameState.phase_index:
		notice_label.text = "시간대가 '%s'으로 전환되었습니다." % GameState.get_phase_name()
	last_day_number = GameState.day_number
	last_phase_index = GameState.phase_index


func _check_ending_stub() -> void:
	if GameState.flags.get("ending_stub_seen", false):
		return
	if GameState.day_number >= 2 and int(GameState.affection.get("catalog_warden", 0)) >= 2 and GameState.flags.get("ending_stub_ready", false):
		GameState.flags["ending_stub_seen"] = true
		_show_dialogue("ending_stub")


func _get_collection_mode_text(title: String) -> String:
	if title == "도감":
		return "관찰 기록과 단서 메모를 열람합니다.\n좌측 탭에서 항목을 골라 상세 내용을 확인하세요."
	return "업무 지침과 생존 규칙을 열람합니다.\n좌측 탭처럼 항목을 골라 세부 페이지를 읽을 수 있습니다."


func _on_collection_item_selected(index: int) -> void:
	_render_collection_detail(index)


func _render_collection_detail(index: int) -> void:
	if index < 0 or index >= current_collection_entries.size():
		collection_detail.text = ""
		return
	var entry: Dictionary = current_collection_entries[index]
	var title := String(entry.get("title", "이름 없는 항목"))
	var subtitle := String(entry.get("subtitle", ""))
	var source := String(entry.get("source", "출처 미상"))
	var page_label := String(entry.get("page_label", "기록"))
	var body := String(entry.get("body", "기록이 비어 있습니다."))
	var lines: Array[String] = []
	lines.append("[b]%s[/b]" % title)
	if not subtitle.is_empty():
		lines.append("[i]%s[/i]" % subtitle)
	lines.append("[color=#7a5d49]%s | 출처: %s[/color]" % [page_label, source])
	lines.append("")
	lines.append(body)
	collection_detail.text = "\n".join(lines)
