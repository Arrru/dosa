extends Control

const UI_THEME_HELPER := preload("res://project/scripts/ui_theme_helper.gd")
const NOVEL_DIR := "res://project/scenes/novel/"

var _background: TextureRect
var _char_left: TextureRect
var _char_center: TextureRect
var _char_right: TextureRect
var _dialogue_panel: PanelContainer
var _speaker_label: Label
var _dialogue_text: RichTextLabel
var _choice_container: VBoxContainer
var _audio_bgm: AudioStreamPlayer
var _audio_sfx: AudioStreamPlayer

var _events: Array = []
var _index: int = 0
var _scene_id: String = ""
var _waiting_for_input: bool = false
var _waiting_for_choice: bool = false
var _typewriter_active: bool = false


func _ready() -> void:
	UI_THEME_HELPER.apply_ui_theme(self)
	_build_ui()
	var scene_path: String = GameState.flags.get("pending_novel_scene", "")
	GameState.flags.erase("pending_novel_scene")
	if scene_path.is_empty():
		SceneRouter.to_game()
		return
	_load_scene(scene_path)
	_start()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var base := ColorRect.new()
	base.anchor_right = 1.0
	base.anchor_bottom = 1.0
	base.color = Color.BLACK
	add_child(base)

	_background = TextureRect.new()
	_background.anchor_right = 1.0
	_background.anchor_bottom = 1.0
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(_background)

	_char_left = _make_char_rect(Vector2(60, 50))
	_char_center = _make_char_rect(Vector2(440, 30))
	_char_right = _make_char_rect(Vector2(820, 50))

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.position = Vector2(0.0, 450.0)
	_dialogue_panel.size = Vector2(1280.0, 270.0)
	_dialogue_panel.visible = false
	add_child(_dialogue_panel)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.offset_left = 24
	margin.offset_top = 16
	margin.offset_right = -24
	margin.offset_bottom = -16
	_dialogue_panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	_speaker_label = Label.new()
	_speaker_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(_speaker_label)

	_dialogue_text = RichTextLabel.new()
	_dialogue_text.bbcode_enabled = false
	_dialogue_text.fit_content = false
	_dialogue_text.custom_minimum_size = Vector2(0, 80)
	_dialogue_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_dialogue_text)

	_choice_container = VBoxContainer.new()
	_choice_container.add_theme_constant_override("separation", 6)
	_choice_container.visible = false
	vbox.add_child(_choice_container)

	_audio_bgm = AudioStreamPlayer.new()
	add_child(_audio_bgm)
	_audio_sfx = AudioStreamPlayer.new()
	add_child(_audio_sfx)


func _make_char_rect(pos: Vector2) -> TextureRect:
	var rect := TextureRect.new()
	rect.position = pos
	rect.size = Vector2(360, 420)
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.visible = false
	add_child(rect)
	return rect


func _load_scene(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("NovelPlayer: cannot open %s" % path)
		SceneRouter.to_game()
		return
	var parsed := JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		push_error("NovelPlayer: invalid JSON in %s" % path)
		SceneRouter.to_game()
		return
	_scene_id = parsed.get("scene_id", "")
	_events = parsed.get("events", [])
	_index = 0


func _start() -> void:
	_index = 0
	_waiting_for_input = false
	_waiting_for_choice = false
	if _events.is_empty():
		_on_scene_completed()
		return
	_process_current()


func _advance() -> void:
	if _waiting_for_choice:
		return
	if _typewriter_active:
		_typewriter_active = false
		return
	if not _waiting_for_input:
		return
	_waiting_for_input = false
	_index += 1
	_process_current()


func _process_current() -> void:
	if _index >= _events.size():
		_on_scene_completed()
		return
	_process_event(_events[_index])


func _process_event(event: Dictionary) -> void:
	match event.get("type", ""):
		"background":
			_handle_background(event)
			_index += 1
			_process_current()
		"bgm_play":
			_handle_bgm_play(event)
			_index += 1
			_process_current()
		"bgm_stop":
			_audio_bgm.stop()
			_index += 1
			_process_current()
		"sfx_play":
			_handle_sfx_play(event)
			_index += 1
			_process_current()
		"character_show":
			_handle_character_show(event)
			_index += 1
			_process_current()
		"character_hide":
			_handle_character_hide(event)
			_index += 1
			_process_current()
		"expression_change":
			_handle_expression_change(event)
			_index += 1
			_process_current()
		"dialogue":
			_handle_dialogue(event)
		"choice":
			_handle_choice(event)
		_:
			push_warning("NovelPlayer: unknown event type '%s'" % event.get("type", ""))
			_index += 1
			_process_current()


func _handle_background(event: Dictionary) -> void:
	var tex := _load_texture(event.get("path", ""))
	if tex:
		_background.texture = tex


func _handle_bgm_play(event: Dictionary) -> void:
	var stream := _load_audio(event.get("path", ""))
	if stream == null:
		return
	_audio_bgm.stream = stream
	if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
		stream.loop = event.get("loop", false)
	_audio_bgm.play()


func _handle_sfx_play(event: Dictionary) -> void:
	var stream := _load_audio(event.get("path", ""))
	if stream:
		_audio_sfx.stream = stream
		_audio_sfx.play()


func _handle_character_show(event: Dictionary) -> void:
	var node := _get_char_node(event.get("position", "center"))
	if node == null:
		return
	var tex := _load_texture(event.get("path", ""))
	if tex:
		node.texture = tex
	node.modulate.a = 0.0
	node.show()
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.3)


func _handle_character_hide(event: Dictionary) -> void:
	for node in [_char_left, _char_center, _char_right]:
		if node == null or not node.visible:
			continue
		var tween := create_tween()
		tween.tween_property(node, "modulate:a", 0.0, 0.3)
		tween.tween_callback(node.hide)


func _handle_expression_change(event: Dictionary) -> void:
	var tex := _load_texture(event.get("path", ""))
	if tex == null:
		return
	for node in [_char_left, _char_center, _char_right]:
		if node != null and node.visible:
			node.texture = tex
			break


func _handle_dialogue(event: Dictionary) -> void:
	_dialogue_panel.show()
	_choice_container.visible = false
	_speaker_label.text = event.get("speaker", "")
	_waiting_for_input = true
	_typewriter_active = true
	_run_typewriter(_dialogue_text, event.get("text", ""))


func _handle_choice(event: Dictionary) -> void:
	_dialogue_panel.show()
	_speaker_label.text = ""
	_dialogue_text.text = event.get("prompt", "")

	for child in _choice_container.get_children():
		child.queue_free()

	_choice_container.visible = true
	_waiting_for_choice = true

	for option in event.get("options", []):
		var btn := Button.new()
		btn.text = option.get("text", "")
		btn.custom_minimum_size = Vector2(0, 40)
		btn.pressed.connect(_on_choice_selected.bind(option))
		_choice_container.add_child(btn)


func _on_choice_selected(option: Dictionary) -> void:
	_waiting_for_choice = false
	_choice_container.visible = false
	for child in _choice_container.get_children():
		child.queue_free()

	# dosa 네이티브 effects 형식 처리
	var effects = option.get("effects", {})
	if not effects.is_empty():
		GameState.apply_effects(effects)

	# mapping-tools variable_set 형식 처리 (레거시 호환)
	var var_set = option.get("variable_set", null)
	if var_set != null:
		var key: String = var_set.get("key", "")
		var value = var_set.get("value", null)
		if not key.is_empty() and value != null:
			GameState.flags[key] = value

	var next: String = option.get("next_scene", "")
	if not next.is_empty():
		var next_path := NOVEL_DIR + next + ".json"
		if FileAccess.file_exists(next_path):
			_load_scene(next_path)
			_start()
			return

	_index += 1
	_process_current()


func _on_scene_completed() -> void:
	_audio_bgm.stop()
	SceneRouter.to_game()


func _run_typewriter(label: RichTextLabel, text: String) -> void:
	label.text = text
	label.visible_characters = 0
	var length := text.length()
	var i := 0
	while i <= length:
		if not _typewriter_active:
			label.visible_characters = -1
			_waiting_for_input = true
			return
		label.visible_characters = i
		i += 1
		await get_tree().create_timer(0.03).timeout
	_typewriter_active = false
	_waiting_for_input = true


func _get_char_node(position: String) -> TextureRect:
	match position:
		"left":  return _char_left
		"right": return _char_right
		_:       return _char_center


func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _load_audio(path: String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as AudioStream


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not event.pressed:
		_advance()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _waiting_for_choice:
			_advance()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			_advance()
