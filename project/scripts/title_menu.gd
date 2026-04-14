extends Control

const UI_THEME_HELPER := preload("res://project/scripts/ui_theme_helper.gd")

var info_label: Label
var overlay_panel: PanelContainer
var overlay_title_label: Label
var overlay_body_label: RichTextLabel
var overlay_action_row: HBoxContainer
var overlay_hint_label: Label


func _ready() -> void:
	UI_THEME_HELPER.apply_ui_theme(self)
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = ContentDB.title_theme["bg"]
	add_child(background)

	for shelf in [
		Rect2(120, 110, 160, 360),
		Rect2(330, 130, 180, 340),
		Rect2(560, 120, 160, 350),
		Rect2(770, 150, 150, 320),
		Rect2(960, 135, 130, 335)
	]:
		var shelf_rect := ColorRect.new()
		shelf_rect.position = shelf.position
		shelf_rect.size = shelf.size
		shelf_rect.color = ContentDB.title_theme["shelf"]
		add_child(shelf_rect)

	var candle := ColorRect.new()
	candle.position = Vector2(905, 130)
	candle.size = Vector2(14, 54)
	candle.color = ContentDB.title_theme["accent"]
	add_child(candle)

	var overlay := ColorRect.new()
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.color = ContentDB.title_theme["overlay"]
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.size = Vector2(420, 520)
	panel.position = Vector2(120, 100)
	add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "괴담 도서관(도사)"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	layout.add_child(title)

	var subtitle := Label.new()
	#subtitle.text = "메뉴얼 괴담 기반 포인트 앤 클릭 + 선택지 진행"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(subtitle)

	if SaveManager.is_web_environment():
		var web_notice := Label.new()
		web_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		web_notice.text = SaveManager.get_persistence_warning()
		layout.add_child(web_notice)

	_add_menu_button(layout, "새 게임", _on_new_game)
	_add_menu_button(layout, "이어하기", _on_continue)
	_add_menu_button(layout, "근무기록", _on_records)
	_add_menu_button(layout, "설정", _on_settings)
	_add_menu_button(layout, "크레딧", _on_credits)
	_add_menu_button(layout, "종료", _on_quit)

	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	#info_label.text = "빈 저장소에서 구성한 MVP입니다. 무료 교체용 플레이스홀더 비주얼을 사용합니다."
	layout.add_child(info_label)

	_build_overlay()


func _add_menu_button(layout: VBoxContainer, text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 64) if UI_THEME_HELPER.is_mobile() else Vector2(0, 48)
	button.pressed.connect(callback)
	layout.add_child(button)


func _build_overlay() -> void:
	overlay_panel = PanelContainer.new()
	overlay_panel.position = Vector2(600, 90)
	overlay_panel.size = Vector2(560, 540)
	overlay_panel.visible = false
	add_child(overlay_panel)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 22
	margin.offset_top = 22
	margin.offset_right = -22
	margin.offset_bottom = -22
	overlay_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	overlay_title_label = Label.new()
	overlay_title_label.add_theme_font_size_override("font_size", 28)
	layout.add_child(overlay_title_label)

	overlay_hint_label = Label.new()
	overlay_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(overlay_hint_label)

	overlay_body_label = RichTextLabel.new()
	overlay_body_label.custom_minimum_size = Vector2(0, 330)
	overlay_body_label.bbcode_enabled = true
	overlay_body_label.scroll_active = true
	layout.add_child(overlay_body_label)

	overlay_action_row = HBoxContainer.new()
	overlay_action_row.add_theme_constant_override("separation", 8)
	layout.add_child(overlay_action_row)

	var close_button := Button.new()
	close_button.text = "닫기"
	close_button.custom_minimum_size = Vector2(0, 42)
	close_button.pressed.connect(_close_overlay)
	layout.add_child(close_button)


func _clear_overlay_actions() -> void:
	for child in overlay_action_row.get_children():
		child.queue_free()


func _show_overlay(title: String, hint: String, body: String) -> void:
	overlay_panel.visible = true
	overlay_title_label.text = title
	overlay_hint_label.text = hint
	overlay_body_label.text = body
	_clear_overlay_actions()


func _add_overlay_action(text: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(110, 38)
	button.pressed.connect(callback)
	overlay_action_row.add_child(button)


func _close_overlay() -> void:
	overlay_panel.visible = false


func _on_new_game() -> void:
	SceneRouter.to_save_slots("new")


func _on_continue() -> void:
	SceneRouter.to_save_slots("load")


func _on_records() -> void:
	var overview := SaveManager.get_progress_overview()
	var lines: Array[String] = []
	lines.append("[b]사용 중인 Slot[/b] %d / 3" % overview["used_slots"])
	lines.append("[b]최고 진행 일차[/b] %d일차" % overview["best_day"])
	lines.append("[b]최고 호감도[/b] %d" % overview["highest_affection"])
	lines.append("[b]누적 도감 해금[/b] %d개" % overview["unique_codex_count"])
	lines.append("[b]누적 메뉴얼 해금[/b] %d개" % overview["unique_manual_count"])
	lines.append("[b]엔딩 스텁 확인[/b] %s" % ("예" if overview["ending_seen"] else "아니오"))
	lines.append("[b]2회차 플래그[/b] %s" % ("해금" if overview["second_run_unlocked"] else "잠김"))
	if overview["slot_details"].is_empty():
		lines.append("\n아직 근무기록이 없습니다. 새 게임으로 첫 근무를 시작하세요.")
	else:
		lines.append("\n[b]Slot별 기록[/b]")
		for detail in overview["slot_details"]:
			lines.append("- Slot %d | %s | %d일차 %s | 도감 %d / 메뉴얼 %d" % [detail["slot_id"], detail["player_name"], detail["day_number"], detail["phase_name"], detail["codex_count"], detail["manual_count"]])
	_show_overlay("근무기록", "지금까지 남긴 근무 로그와 프로토타입 진행 요약입니다.", "\n".join(lines))


func _on_settings() -> void:
	_show_overlay("설정", "실제로 적용 가능한 창 표시 설정만 노출합니다.", "[b]화면 모드[/b]와 [b]창 크기[/b]를 바로 바꿀 수 있습니다.\n대사 속도/오디오/키 설정 저장은 이후 확장 범위입니다.")
	if SaveManager.is_web_environment():
		overlay_body_label.text = "[b]웹 버전 설정[/b]\n브라우저에서는 창 크기를 직접 바꾸는 대신 전체화면 전환만 지원합니다. 저장은 브라우저 저장소를 사용하며, 사생활 보호 모드나 사이트 데이터 삭제 시 유지되지 않을 수 있습니다."
		_add_overlay_action("전체화면", _request_web_fullscreen)
	else:
		_add_overlay_action("창모드", func() -> void: _set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED))
		_add_overlay_action("전체화면", func() -> void: _set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN))
		_add_overlay_action("1280x720", func() -> void: _set_window_size(Vector2i(1280, 720)))
		_add_overlay_action("1600x900", func() -> void: _set_window_size(Vector2i(1600, 900)))


func _on_credits() -> void:
	var content: Dictionary = ContentDB.title_overlay_content["credits"]
	_show_overlay(String(content["title"]), "현재 게임 관련 설정 크레딧입니다.", String(content["body"]))


func _on_quit() -> void:
	if SaveManager.is_web_environment():
		_show_overlay("브라우저 종료 안내", "웹 빌드에서는 앱 자체를 종료할 수 없습니다.", "탭을 닫거나 다른 페이지로 이동해 종료하세요. 진행 상황은 저장 버튼 또는 타이틀 복귀 시점에 저장됩니다.")
		return
	get_tree().quit()


func _set_window_mode(mode: int) -> void:
	if DisplayServer.get_name() == "headless":
		overlay_hint_label.text = "헤드리스 환경에서는 창 모드를 변경할 수 없습니다."
		return
	DisplayServer.window_set_mode(mode)
	overlay_hint_label.text = "화면 모드를 변경했습니다."


func _set_window_size(size: Vector2i) -> void:
	if DisplayServer.get_name() == "headless":
		overlay_hint_label.text = "헤드리스 환경에서는 창 크기를 변경할 수 없습니다."
		return
	DisplayServer.window_set_size(size)
	overlay_hint_label.text = "%dx%d 창 크기를 적용했습니다." % [size.x, size.y]


func _request_web_fullscreen() -> void:
	if not SaveManager.is_web_environment():
		_set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	overlay_hint_label.text = "브라우저가 전체화면 요청을 받았습니다. 차단되면 브라우저 권한 설정을 확인하세요."
