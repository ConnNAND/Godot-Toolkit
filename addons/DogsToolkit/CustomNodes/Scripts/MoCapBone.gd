extends Node3D

@export var skeleton : Skeleton3D
@export var bone_name : String
var bone_idx = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if skeleton:
		bone_idx = skeleton.find_bone(bone_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
