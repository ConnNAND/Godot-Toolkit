@tool
extends Node3D

@export var use_bone_not_sprite:bool = false
@export_category("Bone")
@export var skeleton:Skeleton3D
@export var eye_bone_name = "LeftEye"
@export var max_left_rotation_degrees = -10.0
@export var max_right_rotation_degrees = 10.0
@export var max_up_rotation_degrees = 10.0
@export var max_down_rotation_degrees = -10.0
@export var animation_player:AnimationPlayer
@export var close_eye_animation_name:String
var eye = -1
@export_category("Sprite")
@export var sclera:CompressedTexture2D
@export var sclera_scale = 0.1
@export var iris:CompressedTexture2D
@export var iris_scale = 0.5
var sclera_render = Sprite3D.new()
var iris_render = Sprite3D.new()
@export var max_left = -0.3
@export var max_right = 0.3
@export var max_down = -0.3
@export var max_up = 0.3
@export_category("Control")
@export var manual = true
@export var sight_range = 10.0
var old_range = 0.0
@export var blink_interval = 5.0
@export var auto_look_reset = 2
var blink_timer = Timer.new()
var look_timer = Timer.new()
@export_range(-1,1) var look_left_right = 0.0
@export_range(-1,1) var look_down_up = 0.0
var look_point = Vector3.ZERO
@export var target_group = "look_target"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blink_timer.wait_time = blink_interval
	blink_timer.timeout.connect(blink)
	blink_timer.autostart = true
	add_child(blink_timer)
	blink_timer.start()
	blink_timer.one_shot = false
	look_timer.wait_time = auto_look_reset
	look_timer.timeout.connect(adjust_look)
	look_timer.autostart = true
	add_child(look_timer)
	look_timer.start()
	look_timer.one_shot = false
	add_child(sclera_render)
	sclera_render.global_transform.origin = global_transform.origin
	sclera_render.add_child(iris_render)
	iris_render.global_transform.origin = global_transform.origin
	iris_render.transform.origin += Vector3(0,0,0.05)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	blink_timer.wait_time = blink_interval
	look_timer.wait_time = auto_look_reset
	if use_bone_not_sprite and skeleton:
		iris_render.visible = false
		sclera_render.visible = false
		if eye!=-1:
			look_eye_to_point(look_point)
			skeleton.reset_bone_pose(eye)
			skeleton.set_bone_pose_rotation(eye, Quaternion(Vector3.UP, lerpf(deg_to_rad(max_left_rotation_degrees), deg_to_rad(max_right_rotation_degrees), (look_left_right+1)/2))+Quaternion(Vector3.LEFT, lerpf(deg_to_rad(max_down_rotation_degrees), deg_to_rad(max_up_rotation_degrees), (look_down_up+1)/2)))
			#skeleton.set_bone_pose_rotation(eye, Quaternion(Vector3.LEFT, lerpf(deg_to_rad(max_down_rotation_degrees), deg_to_rad(max_up_rotation_degrees), (look_down_up+1)/2)))
		else:
			eye = skeleton.find_bone(eye_bone_name)
	elif not use_bone_not_sprite:
		iris_render.visible = true
		sclera_render.visible = true
		if sclera_render.texture!=sclera or iris_render.texture!=iris or sclera_render.scale.z!=sclera_scale or iris_render.scale.z!=iris_scale:
			sclera_render.texture = sclera
			iris_render.texture = iris
			sclera_render.scale = Vector3(sclera_scale, sclera_scale, sclera_scale)
			iris_render.scale = Vector3(iris_scale, iris_scale, iris_scale)
		look_eye_to_point(look_point)
		iris_render.global_transform.origin = sclera_render.global_transform.origin
		iris_render.transform.origin += Vector3(0,0,0.05)
		iris_render.transform.origin += Vector3(lerpf(max_left, max_right, (look_left_right+1)/2), lerpf(max_down, max_up, (look_down_up+1)/2), 0)

func blink():
	if animation_player:
		animation_player.play(close_eye_animation_name)
		await animation_player.animation_finished
		animation_player.play_backwards(close_eye_animation_name)


func adjust_look():
	if not manual:
		look_point = Vector3.ZERO
		for i in get_tree().get_nodes_in_group(target_group):
			var temp = (global_transform.origin-i.global_transform.origin).length()
			if temp <= sight_range and (look_point==Vector3.ZERO or (global_transform.origin-look_point).length()>temp):
				look_point = i.global_transform.origin

func look_eye_to_point(point):
	if not manual:
		if point == Vector3.ZERO:
			look_left_right = 0.0
			look_down_up = 0.0
		else:
			var temp = (point - global_transform.origin).normalized() * global_transform.basis
			look_left_right = Vector2(temp.x, temp.z).angle_to(Vector2.DOWN)
			look_down_up = Vector2(temp.z, temp.y).angle_to(Vector2.RIGHT)
			#look_left_right = temp.rotation.y
			#look_left_right = global_transform.basis.z.signed_angle_to((point - global_transform.origin).normalized(), global_transform.basis.y)
			look_left_right = clampf(rad_to_deg(look_left_right)/90, -1, 1)
			#look_down_up = -global_transform.basis.z.signed_angle_to((point - global_transform.origin).normalized(), global_transform.basis.x)
			#look_down_up = temp.rotation.x
			look_down_up = clampf(rad_to_deg(-look_down_up)/90, -1, 1)
