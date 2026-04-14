extends RefCounted

class_name UIThemeHelper

const KOREAN_FONT_PATH := "res://project/assets/fonts/NanumGothic.ttf"
const DEFAULT_FONT_SIZE := 20


static func apply_ui_theme(root: Control) -> void:
	if root == null:
		return
	if not ResourceLoader.exists(KOREAN_FONT_PATH):
		return
	var font_resource := load(KOREAN_FONT_PATH)
	if font_resource == null:
		return
	var ui_theme := Theme.new()
	ui_theme.default_font = font_resource
	ui_theme.default_font_size = DEFAULT_FONT_SIZE
	root.theme = ui_theme
