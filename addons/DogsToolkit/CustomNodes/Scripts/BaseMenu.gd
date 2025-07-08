#@tool
extends Control
class_name BaseMenu

@export var BackgroundTexture:CompressedTexture2D = null
@export var ShowHeader = true
@export var HeaderText = "Title"
enum MenuType {MAIN, PAUSE, OTHER}
@export var MenuStyle:MenuType = MenuType.MAIN
var current_style = MenuType.MAIN
@export var PauseUseNextAsMain:bool = false
@export var NextScene:PackedScene = null
@onready var Background = TextureRect.new()
@export var DefaultMouseMode:Input.MouseMode = Input.MOUSE_MODE_CAPTURED
#@export var Nodes = []
var header
var play_button
var resume_button
var return_to_menu_button
var quit_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	
	set_anchors_preset(Control.PRESET_FULL_RECT,true)
	if BackgroundTexture != null:
		Background.texture = BackgroundTexture
		Background.stretch_mode = Background.STRETCH_KEEP_ASPECT_COVERED
	else:
		Background = ColorRect.new()
		Background.color = Color(0.502, 0.502, 0.502, 0.275)
	add_child(Background)
	Background.theme = theme
	
	Background.set_anchors_preset(Control.PRESET_FULL_RECT,true)
	Background.add_child(CenterContainer.new())
	Background.get_child(0).set_anchors_preset(Control.PRESET_FULL_RECT,true)
	Background.get_child(0).theme = theme
	Background.get_child(0).add_child(VBoxContainer.new())
	Background.get_child(0).get_child(0).alignment = VBoxContainer.ALIGNMENT_CENTER
	Background.get_child(0).get_child(0).theme = theme
	
	header = Label.new()
	Background.get_child(0).get_child(0).add_child(header)
	if ShowHeader:
		header.visible = true
		Background.get_child(0).get_child(0).get_child(0).theme = theme
		Background.get_child(0).get_child(0).get_child(0).text = HeaderText
		Background.get_child(0).get_child(0).get_child(0).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		Background.get_child(0).get_child(0).get_child(0).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		header.visible = false
	
	play_button = add_button(NextScene, "Play")
	play_button.visible = false
	resume_button = Button.new()
	resume_button.text = "Resume"
	resume_button.theme = theme
	resume_button.pressed.connect(toggle_pause)
	Background.get_child(0).get_child(0).add_child(resume_button)
	resume_button.visible = false
	return_to_menu_button = add_button(NextScene, "Return to Menu")
	return_to_menu_button.visible = false
	if MenuStyle == MenuType.MAIN:
		play_button.visible = true
		resume_button.visible = false
		return_to_menu_button.visible = false
	elif MenuStyle == MenuType.PAUSE:
		play_button.visible = false
		resume_button.visible = true
		if PauseUseNextAsMain:
			return_to_menu_button.visible = true
	else:
		play_button.visible = false
		resume_button.visible = false
		return_to_menu_button.visible = false
	quit_button = Button.new()
	Background.get_child(0).get_child(0).add_child(quit_button)
	quit_button.visible = false
	quit_button.theme = theme
	quit_button.text = "Quit Game"
	quit_button.pressed.connect(get_tree().quit)
	if MenuStyle == MenuType.MAIN or MenuStyle == MenuType.PAUSE:
		quit_button.visible = true
	else:
		quit_button.visible = false
	
	#for i in get_children():
	#	if i != Background:
	#		i.reparent(Background.get_child(0).get_child(0))
	#		Nodes.append(i)
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if MenuStyle==MenuType.MAIN:
			Background.get_child(0).get_child(0).get_child(1).grab_focus()
		elif MenuStyle==MenuType.PAUSE:
			Background.get_child(0).get_child(0).get_child(2).grab_focus()
		else:
			Background.get_child(0).get_child(0).get_child(5).grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and MenuStyle == MenuType.PAUSE:
		toggle_pause()
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = DefaultMouseMode


func add_button(scene:PackedScene, button_text:String="button"):
	var temp = SceneChangeButton.new()
	temp.theme = theme
	Background.get_child(0).get_child(0).add_child(temp)
	temp.text = button_text
	temp.next_scene = scene
	return temp


func toggle_pause():
	visible = !visible
	get_tree().paused = visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if MenuStyle==MenuType.MAIN:
			Background.get_child(0).get_child(0).get_child(1).grab_focus()
		elif MenuStyle==MenuType.PAUSE:
			Background.get_child(0).get_child(0).get_child(2).grab_focus()
		else:
			Background.get_child(0).get_child(0).get_child(5).grab_focus()
	else:
		Input.mouse_mode = DefaultMouseMode

func update():
	if BackgroundTexture != null:
		Background.texture = BackgroundTexture
		Background.stretch_mode = Background.STRETCH_KEEP_ASPECT_COVERED
	Background.theme = theme
	Background.get_child(0).theme = theme
	Background.get_child(0).get_child(0).theme = theme
	if ShowHeader:
		header.visible = true
		Background.get_child(0).get_child(0).get_child(0).theme = theme
		Background.get_child(0).get_child(0).get_child(0).text = HeaderText
		Background.get_child(0).get_child(0).get_child(0).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		Background.get_child(0).get_child(0).get_child(0).vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	else:
		header.visible = false
	
	play_button.next_scene = NextScene
	play_button.theme = theme
	if MenuStyle == MenuType.MAIN:
		play_button.visible = true
		resume_button.visible = false
		return_to_menu_button.visible = false
	elif MenuStyle == MenuType.PAUSE:
		play_button.visible = false
		resume_button.visible = true
		resume_button.theme = theme
		if PauseUseNextAsMain:
			return_to_menu_button.visible = true
			return_to_menu_button.theme = theme
			return_to_menu_button.next_scene = NextScene
	if MenuStyle == MenuType.MAIN or MenuStyle == MenuType.PAUSE:
		quit_button.visible = true
		quit_button.theme = theme
	else:
		quit_button.visible = false
	
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if MenuStyle==MenuType.MAIN:
			Background.get_child(0).get_child(0).get_child(1).grab_focus()
		elif MenuStyle==MenuType.PAUSE:
			Background.get_child(0).get_child(0).get_child(2).grab_focus()
		else:
			Background.get_child(0).get_child(0).get_child(5).grab_focus()
