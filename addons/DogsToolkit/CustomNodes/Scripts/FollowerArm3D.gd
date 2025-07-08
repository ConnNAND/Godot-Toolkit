extends SpringArm3D
class_name FollowerArm3D

@export var target:Node3D
var current_location = Vector3.UP
var following_distance = 3
@export var following_speed = 3.0
@export var vertical_offset = 1.5
@export var stay_behind = true

# Called when the node enters the scene tree for the first time.
func _ready():
	following_distance = spring_length


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target!=null:
		if stay_behind:
			current_location = lerp(global_transform.origin, Vector3(target.global_transform.origin.x + target.global_transform.basis.z.x*following_distance, target.global_transform.origin.y + vertical_offset, target.global_transform.origin.z + target.global_transform.basis.z.z*following_distance), delta*(following_speed/following_distance))
		elif (target.global_transform.origin - global_transform.origin).length() > following_distance:
			current_location = lerp(global_transform.origin, Vector3(target.global_transform.origin.x, target.global_transform.origin.y + vertical_offset, target.global_transform.origin.z), delta*(following_speed/following_distance))
		global_transform.origin = current_location
		look_at(target.global_transform.origin, Vector3.UP)
