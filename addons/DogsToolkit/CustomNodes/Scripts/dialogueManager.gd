extends Label

@export_enum("Text List", ".txt File") var text_mode : int
#if using .txt mode, just make the first item in the list a file path
@export var text_array : PackedStringArray
@export var start_line_index = 0
@export var delimiter = "\n"
@export var end_signal = "<SPLIT>"
#@export var branch_signal = "<SPLIT>"
@export var text_display_retarget : Node

@export_category("Sound")
@export var use_audio = false
@export var audio_array : Array[AudioStream]
@export var audio_bus = "Master"
@export var SpatialAudioSource : Node3D
@export var volume_db = 0.0
var audio_player

@export_category("Animation")
@export var use_animations = false
@export var animation_array : PackedStringArray
#^uses animation names, because exported godot animations are wack
@export var animation_player : AnimationPlayer
@export var idle_pose : String

@export_category("Speed")
@export var auto_start = false
@export var display_delay = 0.0
var display_timer = display_delay
@export var auto_advance = false
@export var advance_wait = 3.0
var advance_timer = advance_wait

var current_line = -1
var writing = false
var active_line = ""
var finished = false


func _ready() -> void:
	if SpatialAudioSource:
		audio_player = SpatializedAudioStreamPlayer3D.new()
		audio_player.bus = audio_bus
		#audio_player.global_transform = SpatialAudioSource.global_transform
		SpatialAudioSource.add_child.call_deferred(audio_player)
	else:
		audio_player = AudioStreamPlayer.new()
		audio_player.bus = audio_bus
		add_child(audio_player)
	audio_player.volume_db = volume_db
	if text_mode==1:
		var file = FileAccess.open(text_array[0],FileAccess.READ)
		file = file.get_as_text()
		file = file.split(delimiter)
		while start_line_index > 0:
			file.remove_at(0)
			start_line_index-=1
		if file.find(end_signal)!=-1:
			var temp = file.find(end_signal)
			while file.size() > temp:
				file.remove_at(temp)
		text_array = file
	if auto_start:
		advance_text()



func _process(delta: float) -> void:
	if writing:
		display_timer -= delta
		if not active_line.is_empty() and display_timer<=0:
			if not text_display_retarget:
				text += active_line[0]
			else: 
				text_display_retarget.text += active_line[0]
			active_line = active_line.trim_prefix(active_line[0])
			display_timer = display_delay
		elif active_line.is_empty():
			writing = false
	elif auto_advance and current_line <= text_array.size():
		if use_audio:
			if not audio_player.playing and audio_array.size() > current_line:
				if audio_array[current_line]:
					advance_text()
				elif advance_timer <= 0:
					advance_text()
					advance_timer = advance_wait
				else:
					advance_timer -= delta
			elif advance_timer <= 0:
				advance_text()
				advance_timer = advance_wait
			else:
				advance_timer -= delta
		elif advance_timer <= 0:
			advance_text()
			advance_timer = advance_wait
		else:
			advance_timer -= delta



func advance_text():
	finished = false
	if current_line<text_array.size()-1:
		visible = true
		current_line += 1
		if not text_display_retarget:
			text = ""
		else: 
			text_display_retarget.text = ""
		active_line = text_array[current_line]
		writing = true
		if use_audio and audio_array.size() > current_line:
			if audio_array[current_line]:
				audio_player.stream = audio_array[current_line]
				audio_player.play()
		if use_animations and animation_array.size() > current_line:
			if animation_array[current_line]:
				animation_player.play(animation_array[current_line])
			else:
				animation_player.play(idle_pose)
	else:
		if not text_display_retarget:
			text = ""
			visible = false
		else: 
			text_display_retarget.text = ""
			visible = false
		finished = true


func display_text(dialogue_index:int):
	if dialogue_index>=0 and dialogue_index<text_array.size():
		current_line = dialogue_index
		if not text_display_retarget:
			text = ""
		else: 
			text_display_retarget.text = ""
		active_line = text_array[current_line]
		writing = true
		if use_audio and audio_array.size() > current_line:
			audio_player.stream = audio_array[current_line]
			audio_player.play()
		if use_animations and animation_array.size() > current_line:
			animation_player.play(animation_array[current_line])


func display_new_text(dialogue:String, audio:AudioStream=null, animation:String="DEFAULTVALUEOMGITSTHEDEFAULTVALUEANDITSSUPERCRINGE"):
		current_line = text_array.size()
		if not text_display_retarget:
			text = ""
		else: 
			text_display_retarget.text = ""
		active_line = dialogue
		writing = true
		if use_audio and audio!=null:
			audio_player.stream = audio
			audio_player.play()
		if use_animations:
			if animation == "DEFAULTVALUEOMGITSTHEDEFAULTVALUEANDITSSUPERCRINGE":
				animation_player.play(idle_pose)
			else:
				animation_player.play(animation)
