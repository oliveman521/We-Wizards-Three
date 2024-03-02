extends Control
class_name LevelSelectMenu

const PANEL_MOVE_TIME = .1
const LEVEL_INFO_PANEL = preload("uid://x6b2h8oygbu0")
const CARD_UNLOCK_PANEL = preload("uid://byaui7v8uhmbb")


@onready var panel_onscreen_marker: Marker2D = %"Panel Onscreen Marker"
@onready var panel_offscreen_marker: Marker2D = %"Panel Offscreen Marker"

@onready var deck_building_menu: DeckBuildingMenu = %"Deck Building Menu" as DeckBuildingMenu

var current_info_panel: Node = null

func open_card_unlock_panel(cards: Array[PackedScene]) -> void:
	await close_current_info_panel()
	
	var card_unlock_panel: CardUnlockPanel = CARD_UNLOCK_PANEL.instantiate() as CardUnlockPanel
	add_child(card_unlock_panel)
	current_info_panel = card_unlock_panel
	card_unlock_panel.visible = true
	card_unlock_panel.populate(cards)
	card_unlock_panel.global_position = panel_offscreen_marker.global_position
	move_info_panel_to(panel_onscreen_marker.global_position)

func open_level_info_panel(level_prefab: PackedScene) -> void:
	await close_current_info_panel()
	
	var level_info_panel: LevelInfoPanel = LEVEL_INFO_PANEL.instantiate() as LevelInfoPanel
	add_child(level_info_panel)
	current_info_panel = level_info_panel
	level_info_panel.visible = true
	level_info_panel.populate(level_prefab)
	level_info_panel.global_position = panel_offscreen_marker.global_position
	move_info_panel_to(panel_onscreen_marker.global_position)

func close_current_info_panel() -> void:
	if current_info_panel:
		await move_info_panel_to(panel_offscreen_marker.global_position)
		current_info_panel.queue_free()
		current_info_panel = null

func move_info_panel_to(destination: Vector2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(current_info_panel, "global_position", destination,PANEL_MOVE_TIME)
	await tween.finished

