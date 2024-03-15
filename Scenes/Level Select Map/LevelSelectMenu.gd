extends Control
class_name LevelSelectMenu

const PANEL_MOVE_TIME = .1
const LEVEL_INFO_PANEL = preload("uid://0uoyqe487ot1")
const CARD_UNLOCK_PANEL = preload("uid://cq0tjttjd6e6q")
const MISC_INFO_PANEL = preload("uid://bme0pkf3dqjb8")
@onready var overlay_canvas: CanvasLayer = %"Overlay Canvas"


const screen_margin = 20

@onready var deck_building_menu: DeckBuildingMenu = %"Deck Building Menu" as DeckBuildingMenu

var current_info_panel: Node = null

var offscreen_right_point: Vector2:
	get:
		var right_edge_of_screen: float = get_viewport_rect().size.x
		return Vector2(right_edge_of_screen, screen_margin)

func open_card_unlock_panel(cards: Array[PackedScene]) -> void:
	await close_current_info_panel()
	
	var card_unlock_panel: CardUnlockPanel = CARD_UNLOCK_PANEL.instantiate() as CardUnlockPanel
	overlay_canvas.add_child(card_unlock_panel)
	current_info_panel = card_unlock_panel
	card_unlock_panel.visible = true
	card_unlock_panel.populate(cards)
	card_unlock_panel.global_position = offscreen_right_point
	open_panel(card_unlock_panel)

func open_level_info_panel(level_prefab: PackedScene) -> void:
	await close_current_info_panel()
	
	var level_info_panel: LevelInfoPanel = LEVEL_INFO_PANEL.instantiate() as LevelInfoPanel
	overlay_canvas.add_child(level_info_panel)
	current_info_panel = level_info_panel
	level_info_panel.visible = true
	level_info_panel.populate(level_prefab)
	level_info_panel.global_position = offscreen_right_point
	open_panel(level_info_panel)

func open_misc_info_panel(title: String, text1: String, image: Texture, text2: String, button_text: String, color: Color) -> void:
	await close_current_info_panel()
	
	var misc_info_panel: MiscInfoPanel = MISC_INFO_PANEL.instantiate() as MiscInfoPanel
	overlay_canvas.add_child(misc_info_panel)
	current_info_panel = misc_info_panel
	misc_info_panel.visible = true
	misc_info_panel.populate(title, text1, image, text2, button_text, color)
	misc_info_panel.global_position = offscreen_right_point
	open_panel(misc_info_panel)

func open_tutorial_panel(pages: Array[TutorialInfoPage]) -> void:
	for page in pages:
		await open_misc_info_panel(page.title, page.text1, page.image, page.text2, page.button_text, page.color)
		await current_info_panel.tree_exited
		#TODO this gets squirrelly if you don't finish it

func close_current_info_panel() -> void:
	if current_info_panel:
		await move_info_panel_to(offscreen_right_point)
		current_info_panel.queue_free()
		current_info_panel = null

func open_panel(panel: Control) -> void:
	var right_edge_of_screen: float = get_viewport_rect().size.x
	var width_of_panel: float = panel.get_rect().size.x
	await move_info_panel_to(Vector2(right_edge_of_screen - width_of_panel, screen_margin))

func move_info_panel_to(destination: Vector2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(current_info_panel, "global_position", destination,PANEL_MOVE_TIME)
	await tween.finished

