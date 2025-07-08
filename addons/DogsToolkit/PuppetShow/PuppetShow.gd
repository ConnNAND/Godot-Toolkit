extends WorldEnvironment


var interface : XRInterface
@export var animation_player : AnimationPlayer
@export var animation_name : String
@export_category("Skeleton")
var use_BONE_over_BIND = false
var current_animation : Animation
var use_l = null
var use_r = null
var use_h = null
var lhandp
var lhandr
var rhandp
var rhandr
var hipp
var hipr
var recording = false
var time_passed = 0.0
var wait = 0
var lib : AnimationLibrary

var skeletonl : Skeleton3D
var skeletonr : Skeleton3D
var skeletonh : Skeleton3D
var just_started = true
var just_wait = 3
@export var ik_points:Array[SkeletonIK3D]
var anim_pos_tracks:Array = []
var anim_rot_tracks:Array = []
@export var hip_tracker:Node3D

func _ready() -> void:
	ProjectSettings.set_setting("xr/openxr/enabled", true)
	ProjectSettings.set_setting("xr/shaders/enabled", true)
	print("Before recording, make sure you've set your Animation Player and Animation Name in the MocapStudio Properties")
	print("Also be sure to check that your Animation Player Root Node is set properly.")
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		get_viewport().use_xr = true
	lib = AnimationLibrary.new()
	lib.resource_name = animation_name
	lib.resource_local_to_scene
	current_animation = Animation.new()
	current_animation.resource_name = animation_name
	if not use_BONE_over_BIND:
	#	if $"XROrigin3D/Left Hand/BIND_ME_L".remote_path!=null:
	#		lhandp = current_animation.add_track(Animation.TYPE_POSITION_3D)
	#		current_animation.track_set_path(lhandp, str(animation_player.get_path_to($"XROrigin3D/Left Hand/BIND_ME_L".get_node($"XROrigin3D/Left Hand/BIND_ME_L".remote_path))).erase(0,3))
	#		lhandr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
	#		current_animation.track_set_path(lhandr, str(animation_player.get_path_to($"XROrigin3D/Left Hand/BIND_ME_L".get_node($"XROrigin3D/Left Hand/BIND_ME_L".remote_path))).erase(0,3))
	#		use_l = true
	#	if $"XROrigin3D/Right Hand/BIND_ME_R".remote_path!=null:
	#		rhandp = current_animation.add_track(Animation.TYPE_POSITION_3D)
	#		current_animation.track_set_path(rhandp, str(animation_player.get_path_to($"XROrigin3D/Right Hand/BIND_ME_R".get_node($"XROrigin3D/Right Hand/BIND_ME_R".remote_path))).erase(0,3))
	#		rhandr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
	#		current_animation.track_set_path(rhandr, str(animation_player.get_path_to($"XROrigin3D/Right Hand/BIND_ME_R".get_node($"XROrigin3D/Right Hand/BIND_ME_R".remote_path))).erase(0,3))
	#		use_r = true
		if hip_tracker!=null:
			hipp = current_animation.add_track(Animation.TYPE_POSITION_3D)
			current_animation.track_set_path(hipp, str(animation_player.get_path_to(hip_tracker)).erase(0,3))
			hipr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
			current_animation.track_set_path(hipr, str(animation_player.get_path_to(hip_tracker)).erase(0,3))
			use_h = true
		
		for i in range(ik_points.size()):
			anim_pos_tracks.append(current_animation.add_track(Animation.TYPE_POSITION_3D))
			current_animation.track_set_path(anim_pos_tracks[i], str(animation_player.get_path_to(ik_points[i].get_node(ik_points[i].target_node))).erase(0,3))
			anim_rot_tracks.append(current_animation.add_track(Animation.TYPE_ROTATION_3D))
			current_animation.track_set_path(anim_rot_tracks[i], str(animation_player.get_path_to(ik_points[i].get_node(ik_points[i].target_node))).erase(0,3))

	#else:
	#	if $"XROrigin3D/Left Hand/BONE_ME_L".skeleton!=null:
	#		skeletonl = $"XROrigin3D/Left Hand/BONE_ME_L".skeleton
	#		lhandp = current_animation.add_track(Animation.TYPE_POSITION_3D)
	#		current_animation.track_set_path(lhandp, str(animation_player.get_path_to(skeletonl)).erase(0,3)+":"+$"XROrigin3D/Left Hand/BONE_ME_L".bone_name)
	#		lhandr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
	#		current_animation.track_set_path(lhandr, str(animation_player.get_path_to(skeletonl)).erase(0,3)+":"+$"XROrigin3D/Left Hand/BONE_ME_L".bone_name)
	#		use_l = true
	#	if $"XROrigin3D/Right Hand/BONE_ME_R".skeleton!=null:
	#		skeletonr = $"XROrigin3D/Right Hand/BONE_ME_R".skeleton
	#		rhandp = current_animation.add_track(Animation.TYPE_POSITION_3D)
	#		current_animation.track_set_path(rhandp, str(animation_player.get_path_to(skeletonr)).erase(0,3)+":"+$"XROrigin3D/Right Hand/BONE_ME_R".bone_name)
	#		rhandr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
	#		current_animation.track_set_path(rhandr, str(animation_player.get_path_to(skeletonr)).erase(0,3)+":"+$"XROrigin3D/Right Hand/BONE_ME_R".bone_name)
	#		use_r = true
	#	if $XROrigin3D/XRCamera3D/BONE_ME_H.skeleton!=null:
	#		skeletonh = $"XROrigin3D/XRCamera3D/BONE_ME_H".skeleton
	#		headp = current_animation.add_track(Animation.TYPE_POSITION_3D)
	#		current_animation.track_set_path(headp, str(animation_player.get_path_to(skeletonh)).erase(0,3)+":"+$"XROrigin3D/XRCamera3D/BONE_ME_H".bone_name)
	#		headr = current_animation.add_track(Animation.TYPE_ROTATION_3D)
	#		current_animation.track_set_path(headr, str(animation_player.get_path_to(skeletonh)).erase(0,3)+":"+$"XROrigin3D/XRCamera3D/BONE_ME_H".bone_name)
	#		use_h = true
	print("VR Studio ready, enter VR and press the right stick in to pause and play recording, left stick will finish and save!")
	$"Focus Point".mesh.material.albedo_color = Color(0.2, 0.2, 0.2)
	animation_player.active = false

func _process(delta: float) -> void:
	if just_started:
		recording = false
		$"Focus Point".mesh.material.albedo_color = Color(0.2, 0.2, 0.2)
		if just_wait > 0:
			just_wait -= delta
		else:
			just_started = false
	wait-=delta
	if recording and wait<=0:
		wait=0.05
		if not use_BONE_over_BIND:
			#if use_l:
			#	current_animation.track_insert_key(lhandp, time_passed, $"XROrigin3D/Left Hand/BIND_ME_L".global_position)
			#	current_animation.track_insert_key(lhandr, time_passed, Quaternion($"XROrigin3D/Left Hand/BIND_ME_L".global_basis))
			#if use_r:
			#	current_animation.track_insert_key(rhandp, time_passed, $"XROrigin3D/Right Hand/BIND_ME_R".global_position)
			#	current_animation.track_insert_key(rhandr, time_passed, Quaternion($"XROrigin3D/Right Hand/BIND_ME_R".global_basis))
			if use_h:
				current_animation.track_insert_key(hipp, time_passed, hip_tracker.global_position)
				current_animation.track_insert_key(hipr, time_passed, Quaternion(hip_tracker.global_basis))
			for i in range(ik_points.size()):
				current_animation.track_insert_key(anim_pos_tracks[i], time_passed, ik_points[i].get_node(ik_points[i].target_node).global_position)
				current_animation.track_insert_key(anim_rot_tracks[i], time_passed, Quaternion(ik_points[i].get_node(ik_points[i].target_node).global_basis))
		#else:
		#	if use_l:
		#		current_animation.track_insert_key(lhandp, time_passed, $"XROrigin3D/Left Hand/BONE_ME_L".global_position)
		#		current_animation.track_insert_key(lhandr, time_passed, Quaternion($"XROrigin3D/Left Hand/BONE_ME_L".global_basis))
		#	if use_r:
		#		current_animation.track_insert_key(rhandp, time_passed, $"XROrigin3D/Right Hand/BONE_ME_R".global_position)
		#		current_animation.track_insert_key(rhandr, time_passed, Quaternion($"XROrigin3D/Right Hand/BONE_ME_R".global_basis))
		#	if use_h:
		#		current_animation.track_insert_key(headp, time_passed, $"XROrigin3D/XRCamera3D/BONE_ME_H".global_position)
		#		current_animation.track_insert_key(headr, time_passed, Quaternion($"XROrigin3D/XRCamera3D/BONE_ME_H".global_basis))
		time_passed += delta

func _on_right_hand_button_released(name: String) -> void:
	if name=="primary_click":
		#press in on the right stick to toggle recording the animation
		recording = not recording
		#animation_player.active = recording
		if recording:
			$"Focus Point".mesh.material.albedo_color = Color(0.2, 0.9, 0.2)
		else:
			$"Focus Point".mesh.material.albedo_color = Color(0.9, 0.2, 0.2)


func _on_left_hand_button_pressed(name: String) -> void:
	if name=="primary_click":
		recording = false
		animation_player.active = false
		lib.add_animation(animation_name, current_animation)
		animation_player.add_animation_library(animation_name, lib)
		print("Trying Save...")
		current_animation.resource_path = "res://addons/DogsToolkit/Animations/"+animation_name+".res"
		print(ResourceSaver.save(current_animation))
		$"Focus Point".mesh.material.albedo_color = Color(0.7, 0.7, 0.9)
