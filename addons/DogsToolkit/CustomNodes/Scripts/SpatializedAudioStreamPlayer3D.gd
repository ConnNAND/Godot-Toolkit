extends AudioStreamPlayer3D
class_name SpatializedAudioStreamPlayer3D
#This custom AudioStreamPlayer3D node adds an extra touch of detail to sounds 
#by checking if a wall is in the way of the current listener.
#It does this by casting a ray to the location and seeing if any static bodies or csg colliders are blocking it's path
#The target position attempts to be automatically decided based on if a node is tagged "Player"
#You can change the target by ticking the TargetNotPlayer variable and attaching the instance of your target manually

var target:Node3D
@export var target_not_player:bool = false
@export var custom_target:Node3D = null
var space_state
var update_timer = 0.5
var kill = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not target_not_player:
		target = get_tree().get_first_node_in_group("Player")
	else:
		target = custom_target
	if not target:
		target=self
	space_state = get_world_3d().direct_space_state
	var temp = AudioServer.bus_count
	var temp2
	if AudioServer.get_bus_index("Muffled")==-1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(temp, "Muffled")
		AudioServer.set_bus_volume_db(temp, 0)
		AudioServer.set_bus_send(temp, bus)
		temp2 = AudioEffectLowPassFilter.new()
		temp2.cutoff_hz = 2000
		temp2.resonance = 0.5
		temp2.db = AudioEffectFilter.FILTER_6DB
		AudioServer.add_bus_effect(temp, temp2)
		temp = AudioServer.bus_count
	if AudioServer.get_bus_index("Far")==-1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(temp, "Far")
		AudioServer.set_bus_volume_db(temp, -6)
		AudioServer.set_bus_send(temp, bus)
		temp2 = AudioEffectReverb.new()
		temp2.room_size = 0.8
		temp2.damping = 0.5
		temp2.spread = 1
		temp2.hipass = 0
		temp2.dry = 1
		temp2.wet = 0.5
		AudioServer.add_bus_effect(temp, temp2)
		temp = AudioServer.bus_count
	if AudioServer.get_bus_index("Far & Muffled")==-1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(temp, "Far & Muffled")
		AudioServer.set_bus_volume_db(temp, -26)
		AudioServer.set_bus_send(temp, "Far")
		temp2 = AudioEffectLowPassFilter.new()
		temp2.cutoff_hz = 2000
		temp2.resonance = 0.5
		temp2.db = AudioEffectFilter.FILTER_6DB
		AudioServer.add_bus_effect(temp, temp2)
		temp = AudioServer.bus_count


func _physics_process(_delta):
	space_state = get_world_3d().direct_space_state

func _process(delta: float) -> void:
	if kill:
		if not playing:
			queue_free()
	if playing and update_timer > 0 and stream.loop:
		update_timer -= delta
	elif playing and stream.loop:
		update_timer = 0.5
		var distance_vec = target.global_transform.origin - global_transform.origin
		var ray = global_transform.origin + (distance_vec).normalized()*20
		var query = PhysicsRayQueryParameters3D.create(global_transform.origin, ray)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if result!={}:
			if result["collider"] is StaticBody3D or result["collider"] is CSGCombiner3D or result["collider"] is CSGBox3D or result["collider"] is CSGCylinder3D or result["collider"] is CSGMesh3D or result["collider"] is CSGPolygon3D or result["collider"] is CSGSphere3D or result["collider"] is CSGTorus3D or result["collider"] is CollisionPolygon3D:
				#if distance_vec.length() > 20:
				#	if bus != "Far & Muffled":
				#		bus = "Far & Muffled"
				if bus != "Muffled":
					bus = "Muffled"
			elif bus!="Master" and bus!= "Far":
				bus = "Master"
		#if distance_vec.length() > 20 and bus!="Far & Muffled":
		#	if bus != "Far":
		#		bus = "Far"
		elif bus!="Master":
			bus = "Master"


func play_sound(time:float=0.0)-> void:
	var distance_vec = target.global_transform.origin - global_transform.origin
	var ray = global_transform.origin + (distance_vec).normalized()*20
	var query = PhysicsRayQueryParameters3D.create(global_transform.origin, ray)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result!={}:
		if result["collider"] is StaticBody3D or result["collider"] is CSGCombiner3D or result["collider"] is CSGBox3D or result["collider"] is CSGCylinder3D or result["collider"] is CSGMesh3D or result["collider"] is CSGPolygon3D or result["collider"] is CSGSphere3D or result["collider"] is CSGTorus3D or result["collider"] is CollisionPolygon3D:
			if distance_vec.length() > 20:
				if bus != "Far & Muffled":
					bus = "Far & Muffled"
			if bus != "Muffled":
				bus = "Muffled"
		elif bus!="Master" and bus!= "Far":
			bus = "Master"
	if distance_vec.length() > 20 and bus!="Far & Muffled":
		if bus != "Far":
			bus = "Far"
	elif bus!="Master":
		bus = "Master"
	play(time)

func detatch_play():
	reparent(get_tree().get_root().get_child(0))
	play_sound()
	kill = true
