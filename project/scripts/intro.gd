extends Control

const INTRO_VIDEO_PATH := "res://project/assets/video/intro.ogv"
#const UI_THEME:= "res://project/assets/fonts/ui_theme.tres"

var flame: ColorRect
var status_label: Label
var flicker_timer: Timer
var continue_button: Button
var fallback_nodes: Array[CanvasItem] = []
var video_player: VideoStreamPlayer
var video_notice_label: Label


func _ready() -> void:
	#theme = load(UI_THEME)
	_build_ui()
	if not _try_play_intro_video():
		_start_flicker()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = Color("120d16")
	add_child(background)
	fallback_nodes.append(background)

	var glow := ColorRect.new()
	glow.position = Vector2(500, 120)
	glow.size = Vector2(280, 280)
	glow.color = Color(1.0, 0.82, 0.45, 0.08)
	add_child(glow)
	fallback_nodes.append(glow)

	var candle_body := ColorRect.new()
	candle_body.position = Vector2(620, 220)
	candle_body.size = Vector2(40, 180)
	candle_body.color = Color("efe1c1")
	add_child(candle_body)
	fallback_nodes.append(candle_body)

	flame = ColorRect.new()
	flame.position = Vector2(628, 170)
	flame.size = Vector2(24, 60)
	flame.color = Color("ffd37a")
	add_child(flame)
	fallback_nodes.append(flame)

	var title := Label.new()
	title.position = Vector2(240, 70)
	title.size = Vector2(800, 80)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.text = "괴담 도서관(도사)"
	add_child(title)
	fallback_nodes.append(title)

	var body := Label.new()
	body.position = Vector2(260, 430)
	body.size = Vector2(760, 120)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.text = "본 작품의 배경과 설정은 허구입니다.\n 당신은 수상한 계약 조건에 이끌려 도서관에 취직한 신입 사서로서, 규칙을 익히고 기묘한 손님들 사이에서 살아남아야 합니다."
	add_child(body)
	fallback_nodes.append(body)

	status_label = Label.new()
	status_label.position = Vector2(310, 560)
	status_label.size = Vector2(660, 36)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.text = "촛불이 흔들리는 동안 안내를 읽고, 준비가 되면 계속하세요."
	add_child(status_label)
	fallback_nodes.append(status_label)

	continue_button = Button.new()
	continue_button.position = Vector2(520, 620)
	continue_button.size = Vector2(240, 54)
	continue_button.text = "타이틀로 이동"
	continue_button.pressed.connect(_on_continue_pressed)
	add_child(continue_button)
	fallback_nodes.append(continue_button)

	video_notice_label = Label.new()
	video_notice_label.position = Vector2(140, 640)
	video_notice_label.size = Vector2(1000, 32)
	video_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	video_notice_label.visible = false
	add_child(video_notice_label)


func _try_play_intro_video() -> bool:
	if not ResourceLoader.exists(INTRO_VIDEO_PATH):
		video_notice_label.visible = true
		video_notice_label.text = "인트로 영상이 없어 대체 인트로를 표시합니다. intro.ogv를 추가하면 영상이 먼저 재생됩니다."
		return false
	video_player = VideoStreamPlayer.new()
	video_player.anchor_right = 1.0
	video_player.anchor_bottom = 1.0
	video_player.expand = true
	video_player.autoplay = false
	video_player.stream = load(INTRO_VIDEO_PATH)
	video_player.finished.connect(_on_video_finished)
	add_child(video_player)
	move_child(video_player, 0)
	for node in fallback_nodes:
		node.visible = false
	video_notice_label.visible = true
	video_notice_label.text = "인트로 영상을 재생 중입니다. Enter/Space로 건너뛸 수 있습니다."
	video_player.play()
	return true


func _start_flicker() -> void:
	flicker_timer = Timer.new()
	flicker_timer.wait_time = 0.18
	flicker_timer.autostart = true
	flicker_timer.timeout.connect(_on_flicker_timeout)
	add_child(flicker_timer)


func _on_flicker_timeout() -> void:
	var height := randf_range(44.0, 68.0)
	var width := randf_range(18.0, 28.0)
	flame.size = Vector2(width, height)
	flame.position = Vector2(640.0 - width / 2.0, 230.0 - height)
	flame.color = Color(1.0, randf_range(0.72, 0.86), randf_range(0.35, 0.55), randf_range(0.82, 0.96))


func _on_continue_pressed() -> void:
	status_label.text = "도서관의 문이 열린다..."
	SceneRouter.to_title_menu()


func _on_video_finished() -> void:
	SceneRouter.to_title_menu()


func _unhandled_input(event: InputEvent) -> void:
	if video_player == null:
		return
	if event.is_action_pressed("ui_accept"):
		_on_video_finished()
		return
	if event is InputEventMouseButton and event.pressed:
		_on_video_finished()
