extends Control

var message_label: Label
const UI_THEME:= "res://project/assets/fonts/ui_theme.tres"

func _ready() -> void:
	theme = load(UI_THEME)
	_build_ui()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = Color("1b1620")
	add_child(background)

	var root := VBoxContainer.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 70
	root.offset_top = 50
	root.offset_right = -70
	root.offset_bottom = -40
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	var title := Label.new()
	title.text = "세이브 슬롯 선택 - %s" % ("새 게임" if GameState.pending_save_menu_mode == "new" else "이어하기")
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	message_label = Label.new()
	message_label.text = "슬롯을 선택하세요."
	root.add_child(message_label)

	for summary in SaveManager.get_slot_summaries():
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 96)
		button.text = _format_slot_text(summary)
		button.pressed.connect(_on_slot_pressed.bind(summary))
		root.add_child(button)

	var back := Button.new()
	back.text = "뒤로"
	back.custom_minimum_size = Vector2(0, 44)
	back.pressed.connect(SceneRouter.to_title_menu)
	root.add_child(back)


func _format_slot_text(summary: Dictionary) -> String:
	if not summary["has_data"]:
		return "슬롯 %d\n빈 슬롯" % summary["slot_id"]
	return "슬롯 %d\n이름: %s | %d일차 %s | 호감도 %d" % [summary["slot_id"], summary["player_name"], summary["day_number"], summary["phase_name"], summary["affection"]]


func _on_slot_pressed(summary: Dictionary) -> void:
	if GameState.pending_save_menu_mode == "new":
		SceneRouter.to_name_entry(summary["slot_id"])
		return
	if not summary["has_data"]:
		message_label.text = "이 슬롯에는 불러올 데이터가 없습니다."
		return
	if SaveManager.load_slot(summary["slot_id"]):
		SceneRouter.to_game()
	else:
		message_label.text = "세이브를 불러오지 못했습니다."
