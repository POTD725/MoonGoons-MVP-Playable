extends SceneTree

const REQUIRED := [
	"res://project.godot",
	"res://scenes/main.tscn",
	"res://scripts/main.gd",
	"res://scripts/visual_asset_director.gd",
	"res://assets/ui/icons/reward_icons.svg",
	"res://assets/graphics/moongoons_logo.svg",
	"res://assets/graphics/station_hologram.svg",
	"res://assets/graphics/ops_center.svg",
	"res://assets/graphics/detention_block.svg",
	"res://assets/graphics/chief_office.svg",
	"res://assets/graphics/research_lab.svg",
	"res://assets/graphics/armory.svg",
	"res://README.md"
]

func _init() -> void:
	var failures: Array[String] = []
	for path in REQUIRED:
		if not FileAccess.file_exists(path):
			failures.append("Missing required file: " + path)
	var project_file := FileAccess.open("res://project.godot", FileAccess.READ)
	if project_file == null:
		failures.append("Could not open project.godot")
	elif "run/main_scene=\"res://scenes/main.tscn\"" not in project_file.get_as_text():
		failures.append("Main scene is not configured")
	var scene_file := FileAccess.open("res://scenes/main.tscn", FileAccess.READ)
	if scene_file == null:
		failures.append("Could not open main scene")
	elif "visual_asset_director.gd" not in scene_file.get_as_text():
		failures.append("Main scene does not mount the visual asset director")
	if failures.is_empty():
		print("MoonGoons MVP smoke check passed.")
		quit(0)
	for failure in failures:
		printerr(failure)
	quit(1)
