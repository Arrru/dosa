extends Control

const UI_THEME_HELPER := preload("res://project/scripts/ui_theme_helper.gd")

var input_line: LineEdit
var status_label: Label
var confirm_stage := 0

var _panel: PanelContainer
const _PANEL_BASE_Y := 170.0
var _kb_prev_height := 0.0


func _ready() -> void:
	UI_THEME_HELPER.apply_ui_theme(self)
	_build_ui()
	if UI_THEME_HELPER.is_mobile():
		input_line.focus_entered.connect(_on_input_focused)
		input_line.focus_exited.connect(_on_input_unfocused)
	set_process(false)


func _on_input_focused() -> void:
	set_process(true)


func _on_input_unfocused() -> void:
	set_process(false)
	_kb_prev_height = 0.0
	_panel.position.y = _PANEL_BASE_Y


func _process(_delta: float) -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		set_process(false)
		return
	var kb_physical: int = DisplayServer.virtual_keyboard_get_height()
	var kb_h := float(kb_physical)
	if kb_h == _kb_prev_height:
		return
	_kb_prev_height = kb_h
	if kb_h <= 0.0:
		_panel.position.y = _PANEL_BASE_Y
		return
	# Convert physical keyboard height to canvas/logical pixels.
	# get_final_transform().get_scale().y gives the current viewport stretch scale.
	var scale_y := get_viewport().get_final_transform().get_scale().y
	if scale_y <= 0.0:
		return
	var kb_canvas := kb_h / scale_y
	var viewport_h := get_viewport_rect().size.y
	var panel_h := _panel.size.y
	var available_y := viewport_h - kb_canvas
	var target_y := available_y - panel_h - 12.0
	_panel.position.y = clamp(target_y, 8.0, _PANEL_BASE_Y)


func _build_ui() -> void:
	var background := ColorRect.new()
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = Color("171218")
	add_child(background)

	_panel = PanelContainer.new()
	_panel.size = Vector2(560, 360)
	_panel.position = Vector2(360, _PANEL_BASE_Y)
	add_child(_panel)

	var layout := VBoxContainer.new()
	layout.offset_left = 24
	layout.offset_top = 24
	layout.offset_right = -24
	layout.offset_bottom = -24
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.add_theme_constant_override("separation", 14)
	_panel.add_child(layout)

	var title := Label.new()
	title.text = "이름 입력"
	title.add_theme_font_size_override("font_size", 28)
	layout.add_child(title)

	var fiction := Label.new()
	fiction.text = "※ 본 게임의 배경과 설정은 허구입니다.\n이름 확정 후에는 저장 데이터 기준으로 유지됩니다."
	fiction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(fiction)

	input_line = LineEdit.new()
	input_line.placeholder_text = "사서 이름을 입력하세요"
	input_line.max_length = 12
	layout.add_child(input_line)

	status_label = Label.new()
	status_label.text = "이름을 입력한 뒤 확인을 눌러 주세요."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status_label)

	var btn_h := 60.0 if UI_THEME_HELPER.is_mobile() else 46.0

	var confirm_button := Button.new()
	confirm_button.text = "확인"
	confirm_button.custom_minimum_size = Vector2(0, btn_h)
	confirm_button.pressed.connect(_on_confirm_pressed)
	layout.add_child(confirm_button)

	var cancel_button := Button.new()
	cancel_button.text = "취소"
	cancel_button.custom_minimum_size = Vector2(0, btn_h)
	cancel_button.pressed.connect(func() -> void: SceneRouter.to_save_slots("new"))
	layout.add_child(cancel_button)


func _on_confirm_pressed() -> void:
	var cleaned := input_line.text.strip_edges()
	if cleaned.is_empty():
		status_label.text = "이름이 비어 있습니다."
		return
	if confirm_stage == 0:
		confirm_stage = 1
		status_label.text = "'%s' 이름으로 확정하면 저장 데이터에서 변경할 수 없습니다.\n 다시 확인을 누르면 시작합니다." % cleaned
		return
	GameState.start_new_game(GameState.pending_slot_id, cleaned)
	if not SaveManager.save_current_game():
		status_label.text = "초기 저장에 실패했습니다. 브라우저 저장소 또는 쓰기 권한을 확인해 주세요. 그래도 계속 진행합니다."
	SceneRouter.to_game()
