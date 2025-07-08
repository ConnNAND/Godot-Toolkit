extends AudioStreamPlayer

var playback # Will hold the AudioStreamGeneratorPlayback.
@onready var sample_hz = stream.mix_rate
@export var real_sample:AudioStream
#var pulse_hz = 440.0 # The frequency of the sound wave. concert A
var pulse_hz = 261.63 # The frequency of the sound wave. middle C
var phase = 0.0
@export var use_sine = false
var note = 60

func _ready():
	if use_sine:
		play()
		playback = get_stream_playback()
		fill_buffer()
		stop()
	else:
		stream = real_sample


func _process(delta: float) -> void:
	if use_sine:
		fill_buffer()


func fill_buffer():
	var increment = pulse_hz / sample_hz
	var frames_available = playback.get_frames_available()

	for i in range(frames_available):
		playback.push_frame(Vector2.ONE * sin(phase * TAU))
		phase = fmod(phase + increment, 1.0)

func semitone_to_pitch_scale(note:int):
	#function assumes current pitch is middle C
	return pow(2, ((float(note)-60)/12))

func play_note(note:int, length:float=1.0):
	pitch_scale = semitone_to_pitch_scale(note)
	play()
	if use_sine:
		playback = get_stream_playback()
		fill_buffer()
	await get_tree().create_timer(float(length)).timeout
	stop()
	queue_free()
