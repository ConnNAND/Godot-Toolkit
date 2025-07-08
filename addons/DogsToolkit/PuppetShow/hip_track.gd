extends Node3D

@export var skeleton:Skeleton3D
@export var hip_bone:StringName = &"hip"
@export var active_trackers:Array[Node3D]
@export var offset:Vector3
var headnfeet:Array[Node3D] = []

func _ready() -> void:
	for i in active_trackers:
		if i.is_in_group("head") or i.is_in_group("feet"):
			headnfeet.append(i)


func _process(delta: float) -> void:
	var pos = Vector3.ZERO
	var rot = 0
	for i in headnfeet:
		if i.is_in_group("head"):
			pos += i.global_transform.origin
		rot += i.global_rotation.y
	rot = rot/headnfeet.size()
	global_transform.origin = pos + offset
	global_rotation.y = rot
	skeleton.set_bone_global_pose(skeleton.find_bone(hip_bone), global_transform)
