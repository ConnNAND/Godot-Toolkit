extends Camera3D
class_name SpatializedCamera3D
#This is a custom extension of the Camera3D node that adds audio panning based on it's position and distance to nearby walls

var left_gain_mod = 0
var right_gain_mod = 0

@onready var audio_pan:AudioEffectPanner

var left_ear
var right_ear
var back_ear

var playing
var to_play

@export var check_length = 1.41
@export var volume_db = -5

var l1
var l2
var r1
var r2

@export var ambient_tone = preload("ambienttoneindoors.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("SpatializedCamera3DsSpecialAwesomeSuperGroup")
	var efec = -1
	for i in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0,i) is AudioEffectPanner:
			efec = i
	if efec == -1:
		AudioServer.add_bus_effect(0, AudioEffectPanner.new())
		efec = AudioServer.get_bus_effect_count(0)-1
	audio_pan = AudioServer.get_bus_effect(0, efec)
	var temp = AudioStreamPlayer3D.new()
	add_child(temp)
	temp.global_transform.origin = global_transform.origin
	temp.stream = ambient_tone
	temp.volume_db = volume_db
	left_ear = temp
	temp = AudioStreamPlayer3D.new()
	add_child(temp)
	temp.global_transform.origin = global_transform.origin
	temp.stream = ambient_tone
	temp.volume_db = volume_db
	right_ear = temp
	temp = AudioStreamPlayer3D.new()
	add_child(temp)
	temp.global_transform.origin = global_transform.origin
	temp.stream = ambient_tone
	temp.volume_db = volume_db
	back_ear = temp
	left_ear.play()
	right_ear.play()
	back_ear.play()
	
	l1 = RayCast3D.new()
	add_child(l1)
	l1.global_transform.origin = global_transform.origin
	l1.target_position = Vector3(2,0,-1).normalized()*check_length
	l2 = RayCast3D.new()
	add_child(l2)
	l2.global_transform.origin = global_transform.origin
	l2.target_position = Vector3(2,0,1).normalized()*check_length
	r1 = RayCast3D.new()
	add_child(r1)
	r1.global_transform.origin = global_transform.origin
	r1.target_position = Vector3(-2,0,-1).normalized()*check_length
	r2 = RayCast3D.new()
	add_child(r2)
	r2.global_transform.origin = global_transform.origin
	r2.target_position = Vector3(-2,0,1).normalized()*check_length


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	left_ear.global_transform.origin = global_transform.origin + Vector3(-1,0,0.5)
	right_ear.global_transform.origin = global_transform.origin + Vector3(1,0,0.5)
	right_ear.global_transform.origin = global_transform.origin + Vector3(1,0,-1)
	
	left_gain_mod = 0
	if l1.is_colliding():
		left_gain_mod += check_length/2 - (l1.get_collision_point() - l1.global_transform.origin).length() / 2
	if l2.is_colliding():
		left_gain_mod += check_length/2 - (l2.get_collision_point() - l2.global_transform.origin).length() / 2
	
	right_gain_mod = 0
	if r1.is_colliding():
		right_gain_mod += check_length/2 - (r1.get_collision_point() - r1.global_transform.origin).length() / 2
	if r2.is_colliding():
		right_gain_mod += check_length/2 - (r2.get_collision_point() - r2.global_transform.origin).length() / 2
	
	audio_pan.pan = right_gain_mod/check_length - left_gain_mod/check_length



func change_ambience(audiostream:AudioStream):
	ambient_tone = audiostream
	if audiostream != left_ear.stream:
		var old_left = left_ear
		var old_right = right_ear
		var old_back = back_ear
		left_ear = left_ear.duplicate()
		right_ear = right_ear.duplicate()
		back_ear = back_ear.duplicate()
		
		left_ear.stream = audiostream
		right_ear.stream = audiostream
		back_ear.stream = audiostream
		
		add_child(left_ear)
		add_child(right_ear)
		add_child(back_ear)
		
		left_ear.play()
		right_ear.play()
		back_ear.play()
		
		var temp = create_tween().set_parallel(true)
		
		temp.tween_property(left_ear, "volume_db", volume_db-20, 0)
		temp.tween_property(right_ear, "volume_db", volume_db-20, 0)
		temp.tween_property(back_ear, "volume_db", volume_db-20, 0)
		temp.chain().tween_property(left_ear, "volume_db", volume_db, 3)
		temp.set_parallel(true)
		temp.tween_property(right_ear, "volume_db", volume_db, 3)
		temp.tween_property(back_ear, "volume_db", volume_db, 3)
		temp.tween_property(old_left, "volume_db", volume_db-20, 3)
		temp.tween_property(old_right, "volume_db", volume_db-20, 3)
		temp.tween_property(old_back, "volume_db", volume_db-20, 3)
		temp.chain().tween_callback(old_left.queue_free)
		temp.tween_callback(old_right.queue_free)
		temp.tween_callback(old_back.queue_free)
