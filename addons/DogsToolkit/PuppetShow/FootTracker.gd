extends Node3D

@export var xr_origin:XROrigin3D
@export var camera:Camera3D
@export var offset:Vector3 = Vector3(0, 0.5, 0)
var all_feet = []
var step_dir: Vector2
var stepping = false
var stepcheck = false
var step_time = 0.1
var step_timer = step_time

func _ready():
	for i in get_tree().get_nodes_in_group("feet"):
		if i.is_in_group("main_player_feet"):
			all_feet.append(i)

func _process(delta):
	global_transform.origin.y = xr_origin.global_transform.origin.y
	step_dir = Vector2(global_transform.origin.x, global_transform.origin.z) - Vector2(camera.global_transform.origin.x, camera.global_transform.origin.z)
	if step_timer <=0:
		if (step_dir).length() > 0.4:
			stepcheck = false
			for i in all_feet:
				if i.stepping:
					stepcheck = true
					break
			if not stepcheck:
				take_step()
	else: 
		step_timer -= delta

func take_step():
	stepping = true
	var tween_up = create_tween().set_ease(Tween.EASE_OUT)
	tween_up.tween_property(self, "global_position", Vector3(camera.global_transform.origin.x, xr_origin.global_transform.origin.y + offset.y, camera.global_transform.origin.x), 0.25)
	tween_up.tween_callback(self.step_down).set_delay(0.25)

func step_down():
	global_rotation.y = camera.global_rotation.y
	var tween_down = create_tween().set_ease(Tween.EASE_IN)
	var temp = (offset+Vector3(step_dir.normalized().x/5, 0, step_dir.normalized().y/5)).rotated(Vector3.UP, camera.global_basis.z.y)
	temp += Vector3(camera.global_transform.origin.x, 0, camera.global_transform.origin.z)
	tween_down.tween_property(self, "global_position", Vector3(temp.x, xr_origin.global_transform.origin.y, temp.z), 0.25)
	tween_down.tween_callback(self.reset_step).set_delay(0.25)

func reset_step():
	step_timer = step_time
	stepping = false
