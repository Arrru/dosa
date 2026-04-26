extends Node

const TITLE_BG := "res://project/assets/ui/title_bg.svg"
const PORTRAIT_WARDEN := "res://project/assets/portraits/catalog_warden.svg"

var title_theme := {
	"bg": Color("1a1220"),
	"overlay": Color("000000", 0.35),
	"accent": Color("ffd37a"),
	"shelf": Color("4a3752"),
	"paper": Color("efe5cc"),
	"ink": Color("271b23")
}

var view_data := {
	"north": {
		"title": "중앙 서가",
		"background_color": Color("2f2330"),
		"accent_color": Color("6a5060"),
		"floor_color": Color("58424d"),
		"left": "west",
		"right": "east",
		"down": "south",
		"hotspots": ["desk", "cart", "torn_note"]
	},
	"east": {
		"title": "금서 구역",
		"background_color": Color("2b2130"),
		"accent_color": Color("8c6a82"),
		"floor_color": Color("503f49"),
		"left": "north",
		"right": "west",
		"down": "south",
		"hotspots": ["forbidden_shelf", "warden_perch"]
	},
	"west": {
		"title": "창문 쪽 복도",
		"background_color": Color("2f2633"),
		"accent_color": Color("9b8ca2"),
		"floor_color": Color("574552"),
		"left": "east",
		"right": "north",
		"down": "south",
		"hotspots": ["window", "radiator"]
	},
	"south": {
		"title": "생활 구역",
		"background_color": Color("281f2d"),
		"accent_color": Color("7c6678"),
		"floor_color": Color("4f404b"),
		"left": "west",
		"right": "east",
		"down": "north",
		"hotspots": ["manual_drawer", "meal_drawer", "item_drawer", "bedroll"]
	}
}

var hotspot_data := {
	"desk": {
		"label": "책상",
		"rect": Rect2(520, 360, 220, 90),
		"dialogue_id": "desk_manual"
	},
	"cart": {
		"label": "리어카",
		"rect": Rect2(360, 390, 120, 85),
		"dialogue_id": "cart_flavor"
	},
	"torn_note": {
		"label": "찢긴 종이",
		"rect": Rect2(830, 420, 110, 60),
		"dialogue_id": "torn_note"
	},
	"forbidden_shelf": {
		"label": "금서 책장",
		"rect": Rect2(220, 220, 160, 210),
		"dialogue_id": "forbidden_shelf"
	},
	"warden_perch": {
		"label": "기묘한 손님 자리",
		"rect": Rect2(840, 240, 180, 180),
		"dialogue_id": "warden_encounter"
	},
	"window": {
		"label": "창문",
		"rect": Rect2(185, 150, 220, 245),
		"dialogue_id": "window_flavor"
	},
	"radiator": {
		"label": "라디에이터",
		"rect": Rect2(1050, 260, 110, 160),
		"dialogue_id": "radiator_flavor"
	},
	"manual_drawer": {
		"label": "도감/매뉴얼 서랍",
		"rect": Rect2(200, 210, 210, 220),
		"dialogue_id": "manual_drawer"
	},
	"meal_drawer": {
		"label": "식사 서랍",
		"rect": Rect2(450, 210, 210, 220),
		"dialogue_id": "meal_drawer"
	},
	"item_drawer": {
		"label": "수집 아이템 서랍",
		"rect": Rect2(700, 210, 210, 220),
		"dialogue_id": "item_drawer"
	},
	"bedroll": {
		"label": "침낭",
		"rect": Rect2(1000, 230, 150, 140),
		"dialogue_id": "bedroll"
	}
}

var dialogue_data := {
	"arrival_intro": {
		"speaker": "도서관 안내문",
		"portrait": "",
		"text": "9개월 계약, 숙식 제공, 복지 무료. 조건은 수상하지만 이미 들어와 버렸다.\n살아남으려면 규칙을 익히고, 손님들의 눈에 들어야 한다.",
		"choices": [
			{"text": "우선 책상을 살핀다.", "next": "arrival_intro_followup", "effects": {"unlock_manual": ["rules_001"], "flags": {"met_warden": true}}},
			{"text": "계약서를 다시 읽는다.", "next": "arrival_intro_followup", "effects": {"skills": {"research": 1}, "unlock_manual": ["rules_001"], "flags": {"met_warden": true}}}
		]
	},
	"arrival_intro_followup": {
		"speaker": "카탈로그 감시자",
		"portrait": PORTRAIT_WARDEN,
		"text": "신입 사서인가.\n규칙을 모르면 먹히고, 규칙만 따르면 이용당하지.\n 오늘 밤 전까지는 눈치껏 버텨 봐.",
		"choices": [
			{"text": "예의를 갖춰 인사한다.", "effects": {"affection": {"catalog_warden": 1}}},
			{"text": "조용히 고개만 끄덕인다.", "effects": {"skills": {"empathy": 1}}}
		]
	},
	"desk_manual": {
		"speaker": "책상 위 매뉴얼",
		"portrait": "",
		"text": "첫 장에는 이렇게 적혀 있다.\n'손님이 먼저 이름을 묻더라도, 먼저 대답하지 말 것.'",
		"choices": [
			{"text": "매뉴얼을 읽고 정리한다.", "effects": {"unlock_manual": ["rules_001"], "skills": {"research": 1}, "spend_time": 1}},
			{"text": "책상 서랍을 더듬는다.", "effects": {"unlock_manual": ["rules_002"], "spend_time": 1}}
		]
	},
	"cart_flavor": {
		"speaker": "리어카",
		"portrait": "",
		"text": "반납된 책들이 묘하게 젖어 있다.\n 물인지, 침인지, 다른 무엇인지는 확인하고 싶지 않다.",
		"choices": [
			{"text": "차분히 분류한다.", "effects": {"skills": {"research": 1}, "spend_time": 1}},
			{"text": "모른 척 덮어둔다.", "effects": {"spend_time": 1}}
		]
	},
	"torn_note": {
		"speaker": "찢긴 종이 조각",
		"portrait": "",
		"text": "'귀의는 사랑이 아니라 생존 본능이다.' 조각난 문장이 불길하게 남아 있다.",
		"choices": [
			{"text": "도감에 메모한다.", "effects": {"unlock_codex": ["torn_note_1"]}},
			{"text": "눈에 담아두기만 한다.", "effects": {"skills": {"nerve": 1}}}
		]
	},
	"forbidden_shelf": {
		"speaker": "금서 책장",
		"portrait": "",
		"text": "표지가 없는 책등들이 줄지어 있다. 제목이 없는 대신 누군가의 시선이 빼곡히 꽂혀 있다.",
		"choices": [
			{"text": "제목 대신 냄새를 기억한다.", "effects": {"unlock_codex": ["forbidden_index"], "skills": {"nerve": 1}, "spend_time": 1}},
			{"text": "다음에 읽기로 한다.", "effects": {"spend_time": 1}}
		]
	},
	"warden_encounter": {
		"speaker": "카탈로그 감시자",
		"portrait": PORTRAIT_WARDEN,
		"text": "오늘의 손님을 잘 넘기면 살아남을 거야.\n 잘 보이고 싶다면, 어떤 책을 건네야 하는지도 알아야겠지.",
		"choices": [
			{"text": "추천서를 부탁한다.", "effects": {"affection": {"catalog_warden": 1}, "skills": {"empathy": 1}, "spend_time": 1}},
			{"text": "업무 요령부터 묻는다.", "effects": {"unlock_manual": ["rules_003"], "skills": {"research": 1}, "spend_time": 1}},
			{"text": "어째서 여기 있는지 되묻는다.", "effects": {"unlock_codex": ["warden_profile"], "skills": {"nerve": 1}, "spend_time": 1}}
		]
	},
	"window_flavor": {
		"speaker": "창문 너머",
		"portrait": "",
		"text": "유리 너머 계절은 멈춘 듯하지만, 먼지의 움직임만은 시간이 흐른다는 증거처럼 흔들린다.",
		"choices": [
			{"text": "바깥을 오래 바라본다.", "effects": {"spend_time": 1}},
			{"text": "날씨를 기록한다.", "effects": {"skills": {"research": 1}, "spend_time": 1}}
		]
	},
	"radiator_flavor": {
		"speaker": "라디에이터",
		"portrait": "",
		"text": "금속 틈새에서 낮은 숨소리 같은 소음이 난다. 열기보다 경고에 가깝다.",
		"choices": [
			{"text": "손을 댔다가 바로 뗀다.", "effects": {"skills": {"nerve": 1}}},
			{"text": "이상 징후를 적어 둔다.", "effects": {"unlock_manual": ["rules_004"]}}
		]
	},
	"manual_drawer": {
		"speaker": "서랍",
		"portrait": "",
		"text": "도감과 매뉴얼이 정리된 칸이다. 지금까지 해금한 기록을 확인할 수 있다.",
		"choices": [
			{"text": "매뉴얼을 펼친다.", "effects": {"unlock_manual": ["rules_001"]}},
			{"text": "도감을 정리한다.", "effects": {"unlock_codex": ["starter_index"]}}
		]
	},
	"meal_drawer": {
		"speaker": "식사 상자",
		"portrait": "",
		"text": "라벨 없는 식사 팩이 들어 있다. 먹는 순간 기력이 오르는 대신 한 시간쯤은 그냥 사라질 것 같다.",
		"choices": [
			{"text": "먹고 버틴다.", "effects": {"skills": {"nerve": 1}, "spend_time": 1}},
			{"text": "나중으로 미룬다.", "effects": {}}
		]
	},
	"item_drawer": {
		"speaker": "수집품 칸",
		"portrait": "",
		"text": "찢긴 종이와 메모가 조금씩 모이고 있다. 아직 엔딩으로 이어질 정도는 아니다.",
		"choices": [
			{"text": "정리하면서 숨을 고른다.", "effects": {"unlock_codex": ["torn_note_1"]}},
			{"text": "그냥 닫아 둔다.", "effects": {}}
		]
	},
	"bedroll": {
		"speaker": "침낭",
		"portrait": "",
		"text": "여기서 저장할 수 있다. 잠깐 눈을 붙이면 다음 시간대로 넘어간다.",
		"choices": [
			{"text": "저장하고 쉰다.", "effects": {"spend_time": 1, "flags": {"ending_stub_ready": true}}},
			{"text": "지금은 버틴다.", "effects": {}}
		]
	},
	# --- 둘째날 이후 변형 대화 ---
	# 네이밍 규칙: {기존_dialogue_id}_day{N}
	# game_root.gd가 현재 day_number에 맞는 ID를 자동으로 찾고, 없으면 기존 대화로 fallback
	"warden_encounter_day2": {
		"speaker": "카탈로그 감시자",
		"portrait": PORTRAIT_WARDEN,
		"text": "이틀째군. 아직 살아있다는 게 신기하네.\n오늘은 조금 더 까다로운 손님이 올 거야. 준비해.",
		"choices": [
			{"text": "각오를 다진다.", "effects": {"skills": {"nerve": 1}, "spend_time": 1}},
			{"text": "어떤 손님인지 물어본다.", "effects": {"affection": {"catalog_warden": 1}, "unlock_codex": ["warden_profile"], "spend_time": 1}},
			{"text": "괜찮다고 답한다.", "effects": {"skills": {"empathy": 1}, "spend_time": 1}}
		]
	},
	"desk_manual_day2": {
		"speaker": "책상 위 매뉴얼",
		"portrait": "",
		"text": "두 번째 장에는 이렇게 적혀 있다.\n'밤에 이름을 불리거든, 세 번째는 대답하지 말 것.'",
		"choices": [
			{"text": "규칙을 옮겨 적는다.", "effects": {"unlock_manual": ["rules_005"], "skills": {"research": 1}, "spend_time": 1}},
			{"text": "이미 외웠다.", "effects": {"skills": {"nerve": 1}}}
		]
	},
	"ending_stub": {
		"speaker": "카탈로그 감시자",
		"portrait": PORTRAIT_WARDEN,
		"text": "오늘은 여기까지 살아남았네, 신입 사서. 아직 정규직도, 이직도 멀었지만 적어도 도서관이 널 기억하기 시작했어. 다음 단계에서는 손님별 루트와 더 깊은 사건이 열린다.",
		"choices": [
			{"text": "다음 근무를 준비한다.", "effects": {"flags": {"ending_stub_seen": true, "second_run_unlocked": true}}}
		]
	}
}

var codex_entries := {
	"starter_index": {"title": "기초 도감", "subtitle": "초기 관찰 기록", "source": "생활 구역 서랍", "page_label": "도감-01", "body": "도감은 반복 조우와 기록을 통해 채워진다. 지금은 빈 페이지가 더 많다."},
	"forbidden_index": {"title": "금서 구역 메모", "subtitle": "서가 분류 조각", "source": "금서 책장", "page_label": "도감-02", "body": "표지 없는 책은 제목 대신 기척으로 구분해야 한다."},
	"warden_profile": {"title": "카탈로그 감시자", "subtitle": "주요 손님 관찰 파일", "source": "기묘한 손님 자리", "page_label": "도감-03", "body": "도서관의 규칙을 지키는 손님. 도움인지 감시인지 아직 분간되지 않는다."},
	"torn_note_1": {"title": "찢긴 종이 1", "subtitle": "귀의도 단서", "source": "중앙 서가", "page_label": "도감-04", "body": "귀의는 사랑이 아니라 생존 본능이라는 단서가 적혀 있다."}
}

var manual_entries := {
	"rules_001": {"title": "규칙 1", "subtitle": "호칭 관련 지침", "source": "책상 위 매뉴얼", "page_label": "지침-01", "body": "손님이 먼저 이름을 묻더라도 먼저 대답하지 말 것."},
	"rules_002": {"title": "규칙 2", "subtitle": "반납 도서 취급 지침", "source": "리어카 정리", "page_label": "지침-02", "body": "젖은 책은 즉시 분리하되, 무엇에 젖었는지 확인하지 말 것."},
	"rules_003": {"title": "규칙 3", "subtitle": "대여 응대 요령", "source": "카탈로그 감시자 조언", "page_label": "지침-03", "body": "추천 도서는 손님의 발소리와 시선을 함께 보고 고를 것."},
	"rules_004": {"title": "규칙 4", "subtitle": "설비 이상 대응", "source": "라디에이터 이상 징후", "page_label": "지침-04", "body": "난방기에서 숨소리가 들리면 당직 교대를 요청하지 말 것."}
}

var title_overlay_content := {
	"credits": {
		"title": "크레딧",
		"body": "[b]프로토타입 구현[/b]\nSisyphus\n\n[b]엔진[/b]\nGodot 4.6\n\n[b]비주얼 방향[/b]\n교체 가능한 플레이스홀더 기반 연출\n\n[b]프로젝트 컨셉[/b]\n매뉴얼 괴담 기반 포인트 앤 클릭 + 크리처 미연시 MVP"
	}
}


func get_view(view_id: String) -> Dictionary:
	return view_data.get(view_id, view_data["north"]).duplicate(true)


func get_hotspot(hotspot_id: String) -> Dictionary:
	return hotspot_data.get(hotspot_id, {}).duplicate(true)


func get_dialogue(dialogue_id: String) -> Dictionary:
	return dialogue_data.get(dialogue_id, {}).duplicate(true)


func get_codex_entries(ids: Array[String]) -> Array:
	var entries: Array = []
	for entry_id in ids:
		if codex_entries.has(entry_id):
			var entry: Dictionary = codex_entries[entry_id].duplicate(true)
			entry["id"] = entry_id
			entries.append(entry)
	return entries


func get_manual_entries(ids: Array[String]) -> Array:
	var entries: Array = []
	for entry_id in ids:
		if manual_entries.has(entry_id):
			var entry: Dictionary = manual_entries[entry_id].duplicate(true)
			entry["id"] = entry_id
			entries.append(entry)
	return entries
