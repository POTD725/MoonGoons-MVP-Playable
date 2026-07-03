extends Node

const SAVE_PATH := "user://moongoons_mvp_save.json"
const SPEEDUP_VALUES := [1, 5, 30, 60]

var credits := 900
var supplies := 500
var alliance_tokens := 0
var chief_level := 1
var research_level := 1
var troop_level := 1
var morale := 70
var selected_room_index := 0
var selected_job_id := ""
var last_tick := 0
var jobs: Array = []
var rooms: Array = [
	{"name":"Ops Center","condition":"broken","level":1,"repair_cost":50,"upgrade_cost":80},
	{"name":"Holding Cells","condition":"broken","level":1,"repair_cost":60,"upgrade_cost":95},
	{"name":"Chief Office","condition":"repaired","level":1,"repair_cost":0,"upgrade_cost":120},
	{"name":"Research Lab","condition":"repaired","level":1,"repair_cost":0,"upgrade_cost":110},
	{"name":"Armory","condition":"broken","level":1,"repair_cost":70,"upgrade_cost":105}
]
var officers: Array = [
	{"name":"Officer Nova","injured":false},
	{"name":"Deputy Karr","injured":false},
	{"name":"Scout Zik","injured":true}
]
var speedups := {
	"universal":{"1":4,"5":2,"30":1,"60":1},
	"construction":{"1":0,"5":0,"30":0,"60":0},
	"research":{"1":0,"5":0,"30":0,"60":0},
	"troop_training":{"1":0,"5":0,"30":0,"60":0},
	"healing":{"1":0,"5":0,"30":0,"60":0},
	"mission":{"1":0,"5":0,"30":0,"60":0},
	"rally":{"1":0,"5":0,"30":0,"60":0}
}
var daily_claims := {}
var weekly_claims := {}
var displayed_job_ids: Array = []

var title_label: Label
var wallet_label: Label
var status_label: Label
var station_list: ItemList
var station_detail: Label
var capacity_label: Label
var operations_list: ItemList
var operation_detail: Label
var alliance_label: Label
var player_store_box: VBoxContainer
var daily_store_box: VBoxContainer
var weekly_store_box: VBoxContainer
var inventory_box: VBoxContainer

var player_store := [
	{"id":"build_cache","name":"Construction Cache","icon":"▣","rarity":"Common","category":"Construction","price":90,"currency":"credits","reward":{"supplies":45}},
	{"id":"structural_kit","name":"Structural Reinforcement Kit","icon":"⚙","rarity":"Special","category":"Construction","price":240,"currency":"credits","reward":{"supplies":130}},
	{"id":"research_dossier","name":"Research Dossier","icon":"⚗","rarity":"Common","category":"Research","price":115,"currency":"credits","reward":{"research":1}},
	{"id":"quantum_notebook","name":"Quantum Notebook","icon":"⚗","rarity":"Rare","category":"Research","price":310,"currency":"credits","reward":{"research":2}},
	{"id":"drill_rations","name":"Troop Drill Rations","icon":"✦","rarity":"Common","category":"Troop Training","price":105,"currency":"credits","reward":{"troops":1}},
	{"id":"tactical_sim","name":"Tactical Simulation Pack","icon":"✦","rarity":"Rare","category":"Troop Training","price":300,"currency":"credits","reward":{"troops":2}},
	{"id":"ammo_drop","name":"Emergency Ammo Drop","icon":"✹","rarity":"Special","category":"Combat","price":135,"currency":"credits","reward":{"supplies":25,"morale":5}},
	{"id":"medbay_relief","name":"Medbay Relief Pack","icon":"✚","rarity":"Common","category":"Support","price":85,"currency":"credits","reward":{"heal_all":true}},
	{"id":"universal_1","name":"Universal Speedup: 1 Minute","icon":"◷","rarity":"Common","category":"Speedup","price":12,"currency":"credits","reward":{"speedup":"universal","minutes":1}},
	{"id":"universal_5","name":"Universal Speedup: 5 Minutes","icon":"◷","rarity":"Common","category":"Speedup","price":50,"currency":"credits","reward":{"speedup":"universal","minutes":5}},
	{"id":"universal_30","name":"Universal Speedup: 30 Minutes","icon":"◷","rarity":"Rare","category":"Speedup","price":270,"currency":"credits","reward":{"speedup":"universal","minutes":30}},
	{"id":"universal_60","name":"Universal Speedup: 60 Minutes","icon":"◷","rarity":"Epic","category":"Speedup","price":500,"currency":"credits","reward":{"speedup":"universal","minutes":60}},
	{"id":"officer_file","name":"Officer Development File","icon":"✪","rarity":"Special","category":"Officer","price":175,"currency":"credits","reward":{"morale":12,"supplies":10}},
	{"id":"case_leads","name":"Case Lead Bundle","icon":"⌘","rarity":"Special","category":"Investigation","price":165,"currency":"credits","reward":{"credits":90,"morale":8}}
]

var alliance_daily_pool := [
	{"id":"daily_build_1","name":"Builder Sprint: 1m","icon":"⚙","rarity":"Special","category":"Construction","price":4,"currency":"tokens","reward":{"speedup":"construction","minutes":1}},
	{"id":"daily_build_5","name":"Builder Sprint: 5m","icon":"⚙","rarity":"Special","category":"Construction","price":16,"currency":"tokens","reward":{"speedup":"construction","minutes":5}},
	{"id":"daily_build_30","name":"Builder Sprint: 30m","icon":"⚙","rarity":"Rare","category":"Construction","price":75,"currency":"tokens","reward":{"speedup":"construction","minutes":30}},
	{"id":"daily_build_60","name":"Builder Sprint: 60m","icon":"⚙","rarity":"Epic","category":"Construction","price":140,"currency":"tokens","reward":{"speedup":"construction","minutes":60}},
	{"id":"daily_research_1","name":"Lab Sprint: 1m","icon":"⚗","rarity":"Special","category":"Research","price":4,"currency":"tokens","reward":{"speedup":"research","minutes":1}},
	{"id":"daily_research_5","name":"Lab Sprint: 5m","icon":"⚗","rarity":"Special","category":"Research","price":16,"currency":"tokens","reward":{"speedup":"research","minutes":5}},
	{"id":"daily_research_30","name":"Lab Sprint: 30m","icon":"⚗","rarity":"Rare","category":"Research","price":75,"currency":"tokens","reward":{"speedup":"research","minutes":30}},
	{"id":"daily_research_60","name":"Lab Sprint: 60m","icon":"⚗","rarity":"Epic","category":"Research","price":140,"currency":"tokens","reward":{"speedup":"research","minutes":60}},
	{"id":"daily_training_1","name":"Cadet Drill: 1m","icon":"✦","rarity":"Special","category":"Training","price":4,"currency":"tokens","reward":{"speedup":"troop_training","minutes":1}},
	{"id":"daily_training_5","name":"Cadet Drill: 5m","icon":"✦","rarity":"Special","category":"Training","price":16,"currency":"tokens","reward":{"speedup":"troop_training","minutes":5}},
	{"id":"daily_training_30","name":"Cadet Drill: 30m","icon":"✦","rarity":"Rare","category":"Training","price":75,"currency":"tokens","reward":{"speedup":"troop_training","minutes":30}},
	{"id":"daily_materials","name":"Alliance Materials","icon":"▣","rarity":"Special","category":"Construction","price":28,"currency":"tokens","reward":{"supplies":65}}
]

var alliance_weekly_pool := [
	{"id":"weekly_build_1","name":"Foundry Window: 1m","icon":"⚙","rarity":"Special","category":"Construction","price":6,"currency":"tokens","reward":{"speedup":"construction","minutes":1}},
	{"id":"weekly_build_5","name":"Foundry Window: 5m","icon":"⚙","rarity":"Special","category":"Construction","price":24,"currency":"tokens","reward":{"speedup":"construction","minutes":5}},
	{"id":"weekly_build_30","name":"Foundry Window: 30m","icon":"⚙","rarity":"Rare","category":"Construction","price":110,"currency":"tokens","reward":{"speedup":"construction","minutes":30}},
	{"id":"weekly_build_60","name":"Foundry Window: 60m","icon":"⚙","rarity":"Epic","category":"Construction","price":200,"currency":"tokens","reward":{"speedup":"construction","minutes":60}},
	{"id":"weekly_research_1","name":"Observatory Burst: 1m","icon":"⚗","rarity":"Special","category":"Research","price":6,"currency":"tokens","reward":{"speedup":"research","minutes":1}},
	{"id":"weekly_research_5","name":"Observatory Burst: 5m","icon":"⚗","rarity":"Special","category":"Research","price":24,"currency":"tokens","reward":{"speedup":"research","minutes":5}},
	{"id":"weekly_research_30","name":"Observatory Burst: 30m","icon":"⚗","rarity":"Rare","category":"Research","price":110,"currency":"tokens","reward":{"speedup":"research","minutes":30}},
	{"id":"weekly_research_60","name":"Observatory Burst: 60m","icon":"⚗","rarity":"Epic","category":"Research","price":200,"currency":"tokens","reward":{"speedup":"research","minutes":60}},
	{"id":"weekly_training_30","name":"War Room Drill: 30m","icon":"✦","rarity":"Rare","category":"Training","price":110,"currency":"tokens","reward":{"speedup":"troop_training","minutes":30}},
	{"id":"weekly_healing_30","name":"Medbay Priority: 30m","icon":"✚","rarity":"Rare","category":"Healing","price":110,"currency":"tokens","reward":{"speedup":"healing","minutes":30}},
	{"id":"weekly_mission_30","name":"Field Command: 30m","icon":"✈","rarity":"Rare","category":"Mission","price":125,"currency":"tokens","reward":{"speedup":"mission","minutes":30}},
	{"id":"weekly_rally_30","name":"Alliance Muster: 30m","icon":"◆","rarity":"Rare","category":"Rally","price":120,"currency":"tokens","reward":{"speedup":"rally","minutes":30}}
]

func _ready() -> void:
	load_game()
	ensure_speedups()
	build_ui()
	refresh_all()

func _process(_delta: float) -> void:
	var now := now_unix()
	if now == last_tick:
		return
	last_tick = now
	finish_ready_jobs()
	refresh_header()
	refresh_station()
	refresh_operations()

func now_unix() -> int:
	return int(Time.get_unix_time_from_system())

func build_ui() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var background := ColorRect.new()
	background.color = Color("07101F")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	root.add_child(margin)

	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 8)
	margin.add_child(shell)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	shell.add_child(header)
	title_label = Label.new()
	title_label.text = "MOONGOONS // MVP PLAYABLE"
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color("75D8FF"))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	wallet_label = Label.new()
	wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wallet_label.add_theme_font_size_override("font_size", 16)
	header.add_child(wallet_label)

	status_label = Label.new()
	status_label.text = "COMMAND DECK ONLINE // Start with one Construction Bay and one Research Lab."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("B8C8D8"))
	shell.add_child(status_label)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell.add_child(tabs)
	build_station_tab(tabs)
	build_operations_tab(tabs)
	build_alliance_tab(tabs)
	build_store_tab(tabs)
	build_help_tab(tabs)

func build_station_tab(tabs: TabContainer) -> void:
	var tab := VBoxContainer.new()
	tab.name = "Station"
	tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab)
	var heading := Label.new()
	heading.text = "STATION CONTROL // Repairs and upgrades share Construction Bays"
	heading.add_theme_font_size_override("font_size", 18)
	tab.add_child(heading)
	capacity_label = Label.new()
	capacity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tab.add_child(capacity_label)
	station_list = ItemList.new()
	station_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	station_list.custom_minimum_size = Vector2(0, 260)
	station_list.item_selected.connect(func(index: int): selected_room_index = index; refresh_station())
	tab.add_child(station_list)
	station_detail = Label.new()
	station_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tab.add_child(station_detail)
	var buttons := HBoxContainer.new()
	tab.add_child(buttons)
	add_button(buttons, "Repair Selected Room", start_repair_selected)
	add_button(buttons, "Upgrade Selected Room", start_upgrade_selected)
	add_button(buttons, "Save Game", save_game)

func build_operations_tab(tabs: TabContainer) -> void:
	var tab := VBoxContainer.new()
	tab.name = "Operations"
	tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab)
	var heading := Label.new()
	heading.text = "OPERATIONS QUEUE // Timers continue while the game is closed"
	heading.add_theme_font_size_override("font_size", 18)
	tab.add_child(heading)
	operations_list = ItemList.new()
	operations_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	operations_list.custom_minimum_size = Vector2(0, 230)
	operations_list.item_selected.connect(select_job)
	tab.add_child(operations_list)
	operation_detail = Label.new()
	operation_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tab.add_child(operation_detail)
	var start_row := HBoxContainer.new()
	tab.add_child(start_row)
	add_button(start_row, "Start Research", start_research)
	add_button(start_row, "Train Troops", start_training)
	add_button(start_row, "Heal Injured", start_healing)
	var mission_row := HBoxContainer.new()
	tab.add_child(mission_row)
	add_button(mission_row, "Send Patrol", start_patrol)
	add_button(mission_row, "Start Rally", start_rally)
	var speedup_row := HBoxContainer.new()
	tab.add_child(speedup_row)
	for minutes in SPEEDUP_VALUES:
		add_button(speedup_row, "Use %sm" % minutes, func(): use_speedup(minutes))

func build_alliance_tab(tabs: TabContainer) -> void:
	var tab := VBoxContainer.new()
	tab.name = "Alliance"
	tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab)
	var heading := Label.new()
	heading.text = "ALLIANCE NETWORK // Donations generate Alliance Tokens"
	heading.add_theme_font_size_override("font_size", 18)
	tab.add_child(heading)
	alliance_label = Label.new()
	alliance_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alliance_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(alliance_label)
	var buttons := HBoxContainer.new()
	tab.add_child(buttons)
	add_button(buttons, "Donate 100 Credits (+10 Tokens)", donate_credits)
	add_button(buttons, "Start Alliance Rally", start_rally)

func build_store_tab(tabs: TabContainer) -> void:
	var tab := VBoxContainer.new()
	tab.name = "Store"
	tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(tab)
	var heading := Label.new()
	heading.text = "MOONGOONS SUPPLY EXCHANGE // In-game currency only"
	heading.add_theme_font_size_override("font_size", 18)
	tab.add_child(heading)
	var store_tabs := TabContainer.new()
	store_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(store_tabs)
	player_store_box = add_scroll_page(store_tabs, "Player Store")
	daily_store_box = add_scroll_page(store_tabs, "Alliance Daily")
	weekly_store_box = add_scroll_page(store_tabs, "Alliance Weekly")
	inventory_box = add_scroll_page(store_tabs, "Inventory")

func build_help_tab(tabs: TabContainer) -> void:
	var tab := VBoxContainer.new()
	tab.name = "How To Play"
	tabs.add_child(tab)
	var text := Label.new()
	text.text = "Welcome to the MoonGoons MVP.\n\n1. Repair rooms from Station.\n2. Construction begins with one slot. Upgrade Chief Office and research to unlock more bays.\n3. Research has its own permanent 1/1 Research Lab.\n4. Start patrols, training, healing, and rallies from Operations.\n5. Donate Credits in Alliance to earn Tokens.\n6. Spend Credits or Tokens in Store. Speedups enter the Operations inventory.\n\nThis MVP is local and offline. Every timer, purchase, and save is stored on this device."
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(text)

func add_scroll_page(tabs: TabContainer, tab_name: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = tab_name
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 6)
	scroll.add_child(box)
	return box

func add_button(parent: Container, caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(118, 42)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func refresh_all() -> void:
	refresh_header()
	refresh_station()
	refresh_operations()
	refresh_alliance()
	refresh_store()

func refresh_header() -> void:
	if wallet_label != null:
		wallet_label.text = "Credits: %s   Supplies: %s   Alliance Tokens: %s" % [credits, supplies, alliance_tokens]

func refresh_station() -> void:
	if station_list == null:
		return
	station_list.clear()
	selected_room_index = clamp(selected_room_index, 0, max(0, rooms.size() - 1))
	for room in rooms:
		var state := str(room.get("condition", "broken"))
		var level := int(room.get("level", 1))
		station_list.add_item("%s // L%s // %s" % [str(room.get("name", "Room")), level, state.replace("_", " ").capitalize()])
	if rooms.size() > 0:
		station_list.select(selected_room_index)
		var room: Dictionary = rooms[selected_room_index]
		station_detail.text = "%s\nStatus: %s\nLevel: %s\nRepair cost: %s Supplies\nUpgrade cost: %s Supplies" % [str(room.get("name", "Room")), str(room.get("condition", "broken")).replace("_", " ").capitalize(), int(room.get("level", 1)), int(room.get("repair_cost", 0)), int(room.get("upgrade_cost", 0)) + int(room.get("level", 1)) * 30]
	var construction_text := "Construction Bays: %s/%s active. Start with 1. Bay 2: Chief 2 + Research 2. Bay 3: Chief 5 + Research 5. Bay 4: Chief 10 + Research 10." % [construction_used(), construction_capacity()]
	var research_text := "Research Lab: %s/1 active. Research is separate from construction and remains one slot only." % research_used()
	capacity_label.text = construction_text + "\n" + research_text

func refresh_operations() -> void:
	if operations_list == null:
		return
	operations_list.clear()
	displayed_job_ids.clear()
	var active_jobs := get_running_jobs()
	for job in active_jobs:
		var id := str(job.get("id", ""))
		displayed_job_ids.append(id)
		operations_list.add_item("[%s] %s // %s remaining" % [str(job.get("category", "operation")).capitalize(), str(job.get("title", "Operation")), format_duration(remaining_seconds(job))])
	var current := get_job(selected_job_id)
	if current.is_empty() and not active_jobs.is_empty():
		selected_job_id = str(active_jobs[0].get("id", ""))
		current = get_job(selected_job_id)
	if current.is_empty():
		operation_detail.text = "No active operation selected. Start research, training, healing, a patrol, rally, repair, or upgrade. Use Store speedups after an operation begins."
	else:
		operation_detail.text = "%s\nCategory: %s\nRemaining: %s\nUse a matching speedup or a Universal speedup." % [str(current.get("title", "Operation")), str(current.get("category", "operation")).capitalize(), format_duration(remaining_seconds(current))]

func refresh_alliance() -> void:
	if alliance_label == null:
		return
	var injury_names: Array = []
	for officer in officers:
		if bool(officer.get("injured", false)):
			injury_names.append(str(officer.get("name", "Officer")))
	var injury_text := "No officers need healing." if injury_names.is_empty() else "Injured officers: " + ", ".join(injury_names)
	alliance_label.text = "Alliance Tokens: %s\n\nDonate 100 Credits to receive 10 Alliance Tokens. Tokens purchase rotating Daily and Weekly items in Store.\n\n%s\n\nAlliance rallies improve morale and award supplies when complete." % [alliance_tokens, injury_text]

func refresh_store() -> void:
	if player_store_box == null:
		return
	render_shelf(player_store_box, player_store, "player")
	render_shelf(daily_store_box, rotate_items(alliance_daily_pool, daily_seed(), 10), "daily")
	render_shelf(weekly_store_box, rotate_items(alliance_weekly_pool, weekly_seed(), 10), "weekly")
	render_inventory()

func render_shelf(box: VBoxContainer, items: Array, shelf: String) -> void:
	clear_container(box)
	var intro := Label.new()
	if shelf == "player":
		intro.text = "Permanent player items. Spend Credits only."
	elif shelf == "daily":
		intro.text = "Ten rotating Daily Alliance items. Each one can be claimed once today."
	else:
		intro.text = "Ten rotating Weekly Alliance items. Each one can be claimed once this week."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(intro)
	for item in items:
		box.add_child(make_store_card(item, shelf))

func make_store_card(item: Dictionary, shelf: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 86)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	var icon := Label.new()
	icon.text = str(item.get("icon", "◆"))
	icon.custom_minimum_size = Vector2(44, 44)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 30)
	icon.add_theme_color_override("font_color", rarity_color(str(item.get("rarity", "Common"))))
	row.add_child(icon)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(body)
	var name := Label.new()
	name.text = str(item.get("name", "Store Item"))
	name.add_theme_font_size_override("font_size", 16)
	body.add_child(name)
	var rank := Label.new()
	rank.text = str(item.get("rarity", "Common")).to_upper() + " // " + str(item.get("category", "General")) + " // " + reward_text(item.get("reward", {}))
	rank.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rank.add_theme_color_override("font_color", rarity_color(str(item.get("rarity", "Common"))))
	body.add_child(rank)
	var button := Button.new()
	var claimed := is_claimed(item, shelf)
	var currency := str(item.get("currency", "credits"))
	button.text = "Claimed" if claimed else "Buy\n%s %s" % [int(item.get("price", 0)), "Credits" if currency == "credits" else "Tokens"]
	button.custom_minimum_size = Vector2(116, 48)
	button.disabled = claimed
	button.pressed.connect(func(): purchase_item(item, shelf))
	row.add_child(button)
	return panel

func render_inventory() -> void:
	clear_container(inventory_box)
	var heading := Label.new()
	heading.text = "Timed Operation Speedup Inventory"
	heading.add_theme_font_size_override("font_size", 18)
	inventory_box.add_child(heading)
	var description := Label.new()
	description.text = "Select an active operation in Operations, then use matching category speedups or universal speedups."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_box.add_child(description)
	for category in ["construction", "research", "troop_training", "healing", "mission", "rally", "universal"]:
		var counts: Dictionary = speedups.get(category, {})
		var line := Label.new()
		line.text = "%s // 1m x%s | 5m x%s | 30m x%s | 60m x%s" % [category.replace("_", " ").capitalize(), int(counts.get("1", 0)), int(counts.get("5", 0)), int(counts.get("30", 0)), int(counts.get("60", 0))]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		inventory_box.add_child(line)

func start_repair_selected() -> void:
	if selected_room_index < 0 or selected_room_index >= rooms.size():
		return
	var room: Dictionary = rooms[selected_room_index]
	if str(room.get("condition", "broken")) != "broken":
		set_status("That room is already repaired or currently under repair.")
		return
	if construction_used() >= construction_capacity():
		set_status("All Construction Bays are full. Finish or speed up work first.")
		return
	var cost := int(room.get("repair_cost", 50))
	if supplies < cost:
		set_status("Need %s Supplies to begin that repair." % cost)
		return
	supplies -= cost
	room["condition"] = "under_repair"
	rooms[selected_room_index] = room
	start_job("construction", "repair", "Repair " + str(room.get("name", "Room")), 60 + cost, {"room_index":selected_room_index})

func start_upgrade_selected() -> void:
	if selected_room_index < 0 or selected_room_index >= rooms.size():
		return
	var room: Dictionary = rooms[selected_room_index]
	if str(room.get("condition", "broken")) != "repaired":
		set_status("Repair the room before upgrading it.")
		return
	if construction_used() >= construction_capacity():
		set_status("All Construction Bays are full. Finish or speed up work first.")
		return
	var level := int(room.get("level", 1))
	var cost := int(room.get("upgrade_cost", 100)) + level * 30
	if supplies < cost:
		set_status("Need %s Supplies to begin that upgrade." % cost)
		return
	supplies -= cost
	room["condition"] = "upgrading"
	rooms[selected_room_index] = room
	start_job("construction", "upgrade", "Upgrade " + str(room.get("name", "Room")) + " to L" + str(level + 1), clamp(300 + level * 90, 300, 3600), {"room_index":selected_room_index})

func start_research() -> void:
	if research_used() >= 1:
		set_status("Research Lab is occupied (1/1). Finish or speed up the active project first.")
		return
	var cost := 30 + research_level * 10
	if supplies < cost:
		set_status("Need %s Supplies to begin research." % cost)
		return
	supplies -= cost
	start_job("research", "research", "Research Project L" + str(research_level), clamp(300 + research_level * 90, 300, 3600), {})

func start_training() -> void:
	if has_category_job("troop_training"):
		set_status("Training facility is occupied. Finish or speed up the current class first.")
		return
	var cost := 35 + troop_level * 10
	if supplies < cost:
		set_status("Need %s Supplies to train troops." % cost)
		return
	supplies -= cost
	start_job("troop_training", "training", "Troop Training L" + str(troop_level), clamp(300 + troop_level * 75, 300, 3600), {})

func start_healing() -> void:
	for index in range(officers.size()):
		var officer: Dictionary = officers[index]
		if bool(officer.get("injured", false)) and not has_payload_job("heal", "officer_index", index):
			start_job("healing", "heal", "Heal " + str(officer.get("name", "Officer")), 300, {"officer_index":index})
			set_status("Healing started for " + str(officer.get("name", "Officer")) + ".")
			return
	set_status("No untreated injuries found.")

func start_patrol() -> void:
	if has_category_job("mission"):
		set_status("A field mission is already active. Finish or speed it up first.")
		return
	start_job("mission", "patrol", "Patrol: Crater District Sweep", 900, {})

func start_rally() -> void:
	if has_category_job("rally"):
		set_status("An Alliance Rally is already assembling.")
		return
	if supplies < 30:
		set_status("Need 30 Supplies to launch a rally.")
		return
	supplies -= 30
	start_job("rally", "rally", "Alliance Rally: Moonward Muster", 1800, {})

func donate_credits() -> void:
	if credits < 100:
		set_status("Need 100 Credits to donate.")
		return
	credits -= 100
	alliance_tokens += 10
	set_status("Alliance contribution accepted. +10 Alliance Tokens.")
	save_game()
	refresh_all()

func start_job(category: String, kind: String, title: String, duration: int, payload: Dictionary) -> void:
	var now := now_unix()
	var job := {"id":kind + "_" + str(now) + "_" + str(randi()), "category":category, "kind":kind, "title":title, "ends_at":now + duration, "duration":duration, "payload":payload.duplicate(true)}
	jobs.append(job)
	selected_job_id = str(job.get("id", ""))
	set_status("Operation started: %s // %s" % [title, format_duration(duration)])
	save_game()
	refresh_all()

func select_job(index: int) -> void:
	if index >= 0 and index < displayed_job_ids.size():
		selected_job_id = str(displayed_job_ids[index])
		refresh_operations()

func use_speedup(minutes: int) -> void:
	var job := get_job(selected_job_id)
	if job.is_empty():
		set_status("Select an active operation first.")
		return
	var category := str(job.get("category", "mission"))
	var key := str(minutes)
	var use_category := category
	if int(speedups.get(use_category, {}).get(key, 0)) <= 0:
		use_category = "universal"
	if int(speedups.get(use_category, {}).get(key, 0)) <= 0:
		set_status("No matching %s-minute speedup is available." % minutes)
		return
	speedups[use_category][key] = int(speedups[use_category][key]) - 1
	for i in range(jobs.size()):
		if str(jobs[i].get("id", "")) == selected_job_id:
			jobs[i]["ends_at"] = max(now_unix(), int(jobs[i].get("ends_at", now_unix())) - minutes * 60)
			break
	set_status("Applied %s-minute %s speedup." % [minutes, use_category.replace("_", " ")])
	finish_ready_jobs()
	save_game()
	refresh_all()

func finish_ready_jobs() -> void:
	var now := now_unix()
	var completed: Array = []
	for job in jobs:
		if now >= int(job.get("ends_at", now + 1)):
			completed.append(job)
	for job in completed:
		complete_job(job)
		jobs.erase(job)
	if not completed.is_empty():
		save_game()
		refresh_all()

func complete_job(job: Dictionary) -> void:
	var kind := str(job.get("kind", ""))
	var payload: Dictionary = job.get("payload", {})
	match kind:
		"repair":
			var room_index := int(payload.get("room_index", -1))
			if room_index >= 0 and room_index < rooms.size():
				rooms[room_index]["condition"] = "repaired"
				set_status("Repair complete: " + str(rooms[room_index].get("name", "Room")))
		"upgrade":
			var upgrade_index := int(payload.get("room_index", -1))
			if upgrade_index >= 0 and upgrade_index < rooms.size():
				rooms[upgrade_index]["condition"] = "repaired"
				rooms[upgrade_index]["level"] = int(rooms[upgrade_index].get("level", 1)) + 1
				if str(rooms[upgrade_index].get("name", "")) == "Chief Office":
					chief_level = int(rooms[upgrade_index].get("level", 1))
				set_status("Upgrade complete: " + str(rooms[upgrade_index].get("name", "Room")))
		"research":
			research_level += 1
			credits += 60 + research_level * 10
			set_status("Research complete. Research Level is now %s." % research_level)
		"training":
			troop_level += 1
			morale = min(100, morale + 5)
			set_status("Training complete. Troop Level is now %s." % troop_level)
		"heal":
			var officer_index := int(payload.get("officer_index", -1))
			if officer_index >= 0 and officer_index < officers.size():
				officers[officer_index]["injured"] = false
				set_status(str(officers[officer_index].get("name", "Officer")) + " returned from Medbay.")
		"patrol":
			credits += 140 + troop_level * 15
			supplies += 30
			if randf() < 0.25:
				var officer_pick := randi_range(0, officers.size() - 1)
				officers[officer_pick]["injured"] = true
				set_status("Patrol complete. Reward collected, but " + str(officers[officer_pick].get("name", "Officer")) + " was injured.")
			else:
				set_status("Patrol complete. Credits and supplies recovered.")
		"rally":
			morale = min(100, morale + 15)
			supplies += 50
			alliance_tokens += 8
			set_status("Alliance Rally complete. Morale, Supplies, and Tokens increased.")

func purchase_item(item: Dictionary, shelf: String) -> void:
	if shelf != "player" and is_claimed(item, shelf):
		set_status("That Alliance Store item is already claimed for this cycle.")
		return
	var price := int(item.get("price", 0))
	var currency := str(item.get("currency", "credits"))
	if currency == "credits":
		if credits < price:
			set_status("Not enough Credits for " + str(item.get("name", "this item")) + ".")
			return
		credits -= price
	else:
		if alliance_tokens < price:
			set_status("Not enough Alliance Tokens. Donate Credits in Alliance to earn them.")
			return
		alliance_tokens -= price
	apply_reward(item.get("reward", {}))
	mark_claimed(item, shelf)
	set_status("Store acquired: " + str(item.get("name", "item")) + ".")
	save_game()
	refresh_all()

func apply_reward(reward: Dictionary) -> void:
	if reward.has("credits"):
		credits += int(reward.get("credits", 0))
	if reward.has("supplies"):
		supplies += int(reward.get("supplies", 0))
	if reward.has("morale"):
		morale = min(100, morale + int(reward.get("morale", 0)))
	if reward.has("research"):
		research_level += int(reward.get("research", 0))
	if reward.has("troops"):
		troop_level += int(reward.get("troops", 0))
	if reward.has("heal_all"):
		for i in range(officers.size()):
			officers[i]["injured"] = false
	if reward.has("speedup"):
		var category := str(reward.get("speedup", "universal"))
		var key := str(int(reward.get("minutes", 1)))
		if not speedups.has(category):
			speedups[category] = {"1":0,"5":0,"30":0,"60":0}
		speedups[category][key] = int(speedups[category].get(key, 0)) + 1

func construction_capacity() -> int:
	if chief_level >= 10 and research_level >= 10:
		return 4
	if chief_level >= 5 and research_level >= 5:
		return 3
	if chief_level >= 2 and research_level >= 2:
		return 2
	return 1

func construction_used() -> int:
	var count := 0
	for job in jobs:
		if str(job.get("category", "")) == "construction":
			count += 1
	return count

func research_used() -> int:
	var count := 0
	for job in jobs:
		if str(job.get("category", "")) == "research":
			count += 1
	return count

func has_category_job(category: String) -> bool:
	for job in jobs:
		if str(job.get("category", "")) == category:
			return true
	return false

func has_payload_job(kind: String, key: String, value) -> bool:
	for job in jobs:
		if str(job.get("kind", "")) == kind and job.get("payload", {}).get(key, null) == value:
			return true
	return false

func get_running_jobs() -> Array:
	var result: Array = []
	for job in jobs:
		result.append(job)
	result.sort_custom(func(a, b): return int(a.get("ends_at", 0)) < int(b.get("ends_at", 0)))
	return result

func get_job(id: String) -> Dictionary:
	for job in jobs:
		if str(job.get("id", "")) == id:
			return job
	return {}

func remaining_seconds(job: Dictionary) -> int:
	return max(0, int(job.get("ends_at", now_unix())) - now_unix())

func format_duration(seconds: int) -> String:
	var remaining := max(0, seconds)
	var hours := int(remaining / 3600)
	var minutes := int((remaining % 3600) / 60)
	var secs := int(remaining % 60)
	if hours > 0:
		return "%sh %sm" % [hours, minutes]
	if minutes > 0:
		return "%sm %ss" % [minutes, secs]
	return "%ss" % secs

func reward_text(reward: Dictionary) -> String:
	if reward.has("speedup"):
		return "%s +%sm" % [str(reward.get("speedup", "universal")).replace("_", " ").capitalize(), int(reward.get("minutes", 0))]
	var parts: Array = []
	for key in reward.keys():
		if key == "heal_all":
			parts.append("Heal all")
		else:
			parts.append(str(key).replace("_", " ").capitalize() + " +" + str(reward.get(key)))
	return ", ".join(parts)

func rarity_color(rarity: String) -> Color:
	match rarity:
		"Special": return Color("75E59B")
		"Rare": return Color("74B7FF")
		"Epic": return Color("D38CFF")
		_: return Color("B7C4D0")

func rotate_items(items: Array, seed: int, count: int) -> Array:
	var result: Array = []
	if items.is_empty():
		return result
	var start := posmod(seed, items.size())
	for offset in range(min(count, items.size())):
		result.append(items[(start + offset) % items.size()])
	return result

func daily_seed() -> int:
	var date := Time.get_date_dict_from_system()
	return int(date.get("year", 2026)) * 372 + (int(date.get("month", 1)) - 1) * 31 + int(date.get("day", 1))

func weekly_seed() -> int:
	return int(daily_seed() / 7)

func claim_key(shelf: String, item: Dictionary) -> String:
	var cycle := str(daily_seed()) if shelf == "daily" else str(weekly_seed())
	return shelf + ":" + cycle + ":" + str(item.get("id", ""))

func is_claimed(item: Dictionary, shelf: String) -> bool:
	if shelf == "player":
		return false
	var claims: Dictionary = daily_claims if shelf == "daily" else weekly_claims
	return bool(claims.get(claim_key(shelf, item), false))

func mark_claimed(item: Dictionary, shelf: String) -> void:
	if shelf == "daily":
		daily_claims[claim_key(shelf, item)] = true
	elif shelf == "weekly":
		weekly_claims[claim_key(shelf, item)] = true

func ensure_speedups() -> void:
	for category in ["universal", "construction", "research", "troop_training", "healing", "mission", "rally"]:
		if not speedups.has(category):
			speedups[category] = {}
		for minutes in SPEEDUP_VALUES:
			var key := str(minutes)
			if not speedups[category].has(key):
				speedups[category][key] = 0

func set_status(message: String) -> void:
	if status_label != null:
		status_label.text = "COMMAND DECK // " + message

func clear_container(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func save_game() -> void:
	var data := {
		"credits":credits,
		"supplies":supplies,
		"alliance_tokens":alliance_tokens,
		"chief_level":chief_level,
		"research_level":research_level,
		"troop_level":troop_level,
		"morale":morale,
		"rooms":rooms,
		"officers":officers,
		"jobs":jobs,
		"speedups":speedups,
		"daily_claims":daily_claims,
		"weekly_claims":weekly_claims
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if not (data is Dictionary):
		return
	credits = int(data.get("credits", credits))
	supplies = int(data.get("supplies", supplies))
	alliance_tokens = int(data.get("alliance_tokens", alliance_tokens))
	chief_level = int(data.get("chief_level", chief_level))
	research_level = int(data.get("research_level", research_level))
	troop_level = int(data.get("troop_level", troop_level))
	morale = int(data.get("morale", morale))
	if data.get("rooms", []) is Array:
		rooms = data.get("rooms", rooms)
	if data.get("officers", []) is Array:
		officers = data.get("officers", officers)
	if data.get("jobs", []) is Array:
		jobs = data.get("jobs", jobs)
	if data.get("speedups", {}) is Dictionary:
		speedups = data.get("speedups", speedups)
	if data.get("daily_claims", {}) is Dictionary:
		daily_claims = data.get("daily_claims", daily_claims)
	if data.get("weekly_claims", {}) is Dictionary:
		weekly_claims = data.get("weekly_claims", weekly_claims)
