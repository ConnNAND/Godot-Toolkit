extends Node3D

enum MouthType {BONE, BLEND, IMAGE}
@export var mouth_type:MouthType = MouthType.IMAGE
@export_category("Bone")
@export var skeleton:Skeleton3D
@export var jaw_bone_name = "Jaw"
var jaw_index = -1
@export var jaw_closed_degrees = 0.0
@export var jaw_open_degrees = 10.0
@export var peak_db = -10.0
@export_category("Blendshape")
@export var animation_player_with_visemes:AnimationPlayer
@export var blend_closed:String
@export var blend_ah:String
@export var blend_ee:String
@export var blend_eh:String
@export var blend_oh:String
@export var blend_oo:String
@export var blend_teeth:String
@export_category("Sprite")
var mouth_render = Sprite3D.new()
@export var mouth_scale = 0.1
@export var tex_closed:CompressedTexture2D
@export var tex_ah:CompressedTexture2D
@export var tex_ee:CompressedTexture2D
@export var tex_eh:CompressedTexture2D
@export var tex_oh:CompressedTexture2D
@export var tex_oo:CompressedTexture2D
@export var tex_teeth:CompressedTexture2D
@export_category("Control")
enum MouthShape {CLOSED, AH, EE, EH, OH, OO, TEETH}
@export var audio_bus:String
@export var cutoff_db = -46
@export var hz_leniency = 50
var total_volume = 0
var spectrum:AudioEffectSpectrumAnalyzerInstance
var ah = Vector3(650, 1080, 2650)
var ee = Vector3(290, 1870, 2800)
var eh = Vector3(400, 1700, 2600)
var oh = Vector3(400, 800, 2600)
var oo = Vector3(350, 600, 2700)
var ah_score = 0
var ee_score = 0
var eh_score = 0
var oh_score = 0
var oo_score = 0
var final_score = 0
var formant = MouthShape.CLOSED


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if AudioServer.get_bus_effect_instance(AudioServer.get_bus_index(audio_bus),0) is AudioEffectSpectrumAnalyzerInstance:
		spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index(audio_bus),0)
	else:
		AudioServer.add_bus_effect(AudioServer.get_bus_index(audio_bus), AudioEffectSpectrumAnalyzer.new())
		spectrum = AudioServer.get_bus_effect_instance(AudioServer.get_bus_index(audio_bus),AudioServer.get_bus_effect_count(AudioServer.get_bus_index(audio_bus))-1)
	add_child(mouth_render)
	mouth_render.global_transform = global_transform
	mouth_render.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	total_volume = linear_to_db(spectrum.get_magnitude_for_frequency_range(200, 20000).length())
	ah_score = 0
	ee_score = 0
	eh_score = 0
	oh_score = 0
	oo_score = 0
	#f1
	ah_score += spectrum.get_magnitude_for_frequency_range(ah.x-hz_leniency, ah.x+hz_leniency).length()
	ee_score += spectrum.get_magnitude_for_frequency_range(ee.x-hz_leniency, ee.x+hz_leniency).length()
	eh_score += spectrum.get_magnitude_for_frequency_range(eh.x-hz_leniency, eh.x+hz_leniency).length()
	oh_score += spectrum.get_magnitude_for_frequency_range(oh.x-hz_leniency, oh.x+hz_leniency).length()
	oo_score += spectrum.get_magnitude_for_frequency_range(oo.x-hz_leniency, oo.x+hz_leniency).length()
	#f2
	ah_score += spectrum.get_magnitude_for_frequency_range(ah.y-hz_leniency, ah.y+hz_leniency).length()
	ee_score += spectrum.get_magnitude_for_frequency_range(ee.y-hz_leniency, ee.y+hz_leniency).length()
	eh_score += spectrum.get_magnitude_for_frequency_range(eh.y-hz_leniency, eh.y+hz_leniency).length()
	oh_score += spectrum.get_magnitude_for_frequency_range(oh.y-hz_leniency, oh.y+hz_leniency).length()
	oo_score += spectrum.get_magnitude_for_frequency_range(oo.y-hz_leniency, oo.y+hz_leniency).length()
	#f3
	ah_score += spectrum.get_magnitude_for_frequency_range(ah.z-hz_leniency, ah.z+hz_leniency).length()
	ee_score += spectrum.get_magnitude_for_frequency_range(ee.z-hz_leniency, ee.z+hz_leniency).length()
	eh_score += spectrum.get_magnitude_for_frequency_range(eh.z-hz_leniency, eh.z+hz_leniency).length()
	oh_score += spectrum.get_magnitude_for_frequency_range(oh.z-hz_leniency, oh.z+hz_leniency).length()
	oo_score += spectrum.get_magnitude_for_frequency_range(oo.z-hz_leniency, oo.z+hz_leniency).length()
	final_score = max(ah_score, ee_score, eh_score, oh_score, oo_score)
	if linear_to_db(final_score/3) >= cutoff_db and total_volume>=cutoff_db:
		match final_score:
			ah_score:
				formant = MouthShape.AH
			ee_score:
				formant = MouthShape.EE
			eh_score:
				formant = MouthShape.EH
			oh_score:
				formant = MouthShape.OH
			oo_score:
				formant = MouthShape.OO
	elif total_volume>=cutoff_db:
		formant = MouthShape.TEETH
	else:
		formant = MouthShape.CLOSED
	match mouth_type:
		MouthType.BONE:
			if jaw_index != -1:
				skeleton.reset_bone_pose(jaw_index)
				skeleton.set_bone_pose_rotation(jaw_index, Quaternion(Vector3.LEFT, lerpf(deg_to_rad(jaw_closed_degrees), deg_to_rad(jaw_open_degrees), (total_volume - cutoff_db)/(peak_db - cutoff_db))))
			elif skeleton:
				skeleton.find_bone(jaw_bone_name)
		MouthType.BLEND:
			if animation_player_with_visemes:
				match formant:
					MouthShape.AH:
						animation_player_with_visemes.play(blend_ah)
					MouthShape.EE:
						animation_player_with_visemes.play(blend_ee)
					MouthShape.EH:
						animation_player_with_visemes.play(blend_eh)
					MouthShape.OH:
						animation_player_with_visemes.play(blend_oh)
					MouthShape.OO:
						animation_player_with_visemes.play(blend_oo)
					MouthShape.TEETH:
						animation_player_with_visemes.play(blend_teeth)
					MouthShape.CLOSED:
						animation_player_with_visemes.play(blend_closed)
		MouthType.IMAGE:
			mouth_render.visible = true
			mouth_render.scale = Vector3.ONE * mouth_scale
			match formant:
				MouthShape.AH:
					mouth_render.texture = tex_ah
				MouthShape.EE:
					mouth_render.texture = tex_ee
				MouthShape.EH:
					mouth_render.texture = tex_eh
				MouthShape.OH:
					mouth_render.texture = tex_oh
				MouthShape.OO:
					mouth_render.texture = tex_oo
				MouthShape.TEETH:
					mouth_render.texture = tex_teeth
				MouthShape.CLOSED:
					mouth_render.texture = tex_closed
