extends Node

## Loads actual SVG artwork into the playable MVP's Station screen.
## The main UI remains code-driven, but these graphics are imported by Godot and
## displayed as selectable room visuals rather than placeholder text alone.

const LOGO_TEXTURE = preload("res://assets/graphics/moongoons_logo.svg")
const DEFAULT_ROOM_TEXTURE = preload("res://assets/graphics/station_hologram.svg")
const ROOM_TEXTURES := {
	"Ops Center": preload("res://assets/graphics/ops_center.svg"),
	"Holding Cells": preload("res://assets/graphics/detention_block.svg"),
	"Chief Office": preload("res://assets/graphics/chief_office.svg"),
	"Research Lab": preload("res://assets/graphics/research_lab.svg"),
	"Armory": preload("res://assets/graphics/armory.svg")
}

var room_texture: TextureRect
var room_caption: Label
var game_node: Node

func _ready() -> void:
	call_deferred("_mount_visual_assets")

func _mount_visual_assets() -> void:
	game_node = get_parent()
	var root_control := _find_root_control(game_node)
	var station_detail := game_node.get("station_detail") as Label
	var station_list := game_node.get("station_list") as ItemList
	if root_control == null or station_detail == null or station_list == null:
		call_deferred("_mount_visual_assets")
		return
	if root_control.get_node_or_null("MoonGoonsVisualLogo") == null:
		_add_logo(root_control)
	if station_detail.get_parent().get_node_or_null("RoomVisualPanel") == null:
		_add_room_visual_panel(station_detail)
	if not station_list.item_selected.is_connected(_on_room_selected):
		station_list.item_selected.connect(_on_room_selected)
	_refresh_room_visual()

func _find_root_control(parent: Node) -> Control:
	for child in parent.get_children():
		if child is Control:
			return child as Control
	return null

func _add_logo(root_control: Control) -> void:
	var logo := TextureRect.new()
	logo.name = "MoonGoonsVisualLogo"
	logo.texture = LOGO_TEXTURE
	logo.position = Vector2(430, 2)
	logo.size = Vector2(410, 54)
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.z_index = 4
	root_control.add_child(logo)

func _add_room_visual_panel(station_detail: Label) -> void:
	var parent_box := station_detail.get_parent() as VBoxContainer
	var panel := PanelContainer.new()
	panel.name = "RoomVisualPanel"
	panel.custom_minimum_size = Vector2(0, 122)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	room_texture = TextureRect.new()
	room_texture.custom_minimum_size = Vector2(180, 106)
	room_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	room_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	room_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(room_texture)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	var heading := Label.new()
	heading.text = "LIVE ROOM VISUAL"
	heading.add_theme_font_size_override("font_size", 16)
	heading.add_theme_color_override("font_color", Color("75D8FF"))
	copy.add_child(heading)
	room_caption = Label.new()
	room_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copy.add_child(room_caption)
	parent_box.add_child(panel)
	parent_box.move_child(panel, station_detail.get_index() + 1)

func _on_room_selected(_index: int) -> void:
	call_deferred("_refresh_room_visual")

func _refresh_room_visual() -> void:
	if game_node == null or room_texture == null or room_caption == null:
		return
	var rooms: Array = game_node.get("rooms")
	var room_index := int(game_node.get("selected_room_index"))
	if room_index < 0 or room_index >= rooms.size():
		return
	var room: Dictionary = rooms[room_index]
	var room_name := str(room.get("name", "Station"))
	room_texture.texture = ROOM_TEXTURES.get(room_name, DEFAULT_ROOM_TEXTURE)
	room_caption.text = "Visual asset loaded from assets/graphics/\n%s // Level %s // %s" % [room_name, int(room.get("level", 1)), str(room.get("condition", "unknown")).replace("_", " ").capitalize()]
