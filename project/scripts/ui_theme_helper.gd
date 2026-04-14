extends RefCounted

class_name UIThemeHelper

const KOREAN_FONT_PATH := "res://project/assets/fonts/NanumGothic.ttf"
const DEFAULT_FONT_SIZE := 20
const MOBILE_FONT_SIZE := 22


static func is_mobile() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")


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
	ui_theme.default_font_size = MOBILE_FONT_SIZE if is_mobile() else DEFAULT_FONT_SIZE
	root.theme = ui_theme
