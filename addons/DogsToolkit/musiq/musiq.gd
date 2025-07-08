extends Control

enum Triad {Major, Minor, Augmented, Diminished, Auto}
enum Key_Signatures {Major, Natural_Minor, Harmonic_Minor, Melodic_Minor, Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian}
enum Chord7 {Major, Minor, Dominant, Half_Diminished, Diminished, Auto}

var current_key:Key_Signatures = Key_Signatures.Major
var scale_root:int=60
var note_player = preload("res://addons/DogsToolkit/musiq/note_player.tscn")
var bpm:int = 120
var numerator:int = 4
var denominator:int = 4

@onready var root_label = find_child("RootNote")

var triad_dict = {
	Triad.Major: [0, 4, 7],
	Triad.Minor: [0, 3, 7],
	Triad.Augmented: [0, 4, 8],
	Triad.Diminished: [0, 3, 6]
}

var chord7_dict = {
	Chord7.Major: [Triad.Major, 11],
	Chord7.Minor: [Triad.Minor, 10],
	Chord7.Dominant: [Triad.Major, 10],
	Chord7.Half_Diminished: [Triad.Diminished, 10],
	Chord7.Diminished: [Triad.Minor, 9],
}

var signature_dict = {
	Key_Signatures.Major: [0, 2, 4, 5, 7, 9, 11],
	Key_Signatures.Natural_Minor: [0, 2, 3, 5, 7, 8, 10],
	Key_Signatures.Harmonic_Minor: [0, 2, 3, 5, 7, 8, 11],
	Key_Signatures.Melodic_Minor: [0, 2, 3, 5, 7, 9, 11],
	Key_Signatures.Ionian: [0, 2, 4, 5, 7, 9, 11],
	Key_Signatures.Dorian: [0, 2, 3, 5, 7, 9, 10],
	Key_Signatures.Phrygian: [0, 1, 3, 5, 7, 8, 10],
	Key_Signatures.Lydian: [0, 2, 4, 6, 7, 9, 11],
	Key_Signatures.Mixolydian: [0, 2, 4, 5, 7, 9, 10],
	Key_Signatures.Aeolian: [0, 2, 3, 5, 7, 8, 10],
	Key_Signatures.Locrian: [0, 1, 3, 5, 6, 8, 10]
}

var scale_degree_dict = {
	Key_Signatures.Major: [Triad.Major, Triad.Minor, Triad.Minor, Triad.Major, Triad.Major, Triad.Minor, Triad.Diminished],
	Key_Signatures.Natural_Minor: [Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor, Triad.Minor, Triad.Major, Triad.Major],
	Key_Signatures.Harmonic_Minor: [Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor, Triad.Major, Triad.Major, Triad.Diminished],
	Key_Signatures.Melodic_Minor: [Triad.Minor, Triad.Minor, Triad.Augmented, Triad.Major, Triad.Major, Triad.Diminished, Triad.Diminished],
	Key_Signatures.Ionian: [Triad.Major, Triad.Minor, Triad.Minor, Triad.Major, Triad.Major, Triad.Minor, Triad.Diminished],
	Key_Signatures.Dorian: [Triad.Minor, Triad.Minor, Triad.Major, Triad.Major, Triad.Minor, Triad.Diminished, Triad.Major],
	Key_Signatures.Phrygian: [Triad.Minor, Triad.Major, Triad.Major, Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor],
	Key_Signatures.Lydian: [Triad.Major, Triad.Major, Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor, Triad.Minor],
	Key_Signatures.Mixolydian: [Triad.Major, Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor, Triad.Minor, Triad.Major],
	Key_Signatures.Aeolian: [Triad.Minor, Triad.Diminished, Triad.Major, Triad.Minor, Triad.Minor, Triad.Major, Triad.Major],
	Key_Signatures.Locrian: [Triad.Diminished, Triad.Major, Triad.Minor, Triad.Minor, Triad.Major, Triad.Major, Triad.Minor]
}

var song = []
#fill song with a series of nested lists: 
#[
	#[[60, 64, 67, 71], 1]
	#[[67, 71, 74, 78], 1]
	#[[60, 64, 67, 71], 1]
#]
#the first entry is all of the notes that will be played together
#the second entry is how long they will be played

func _ready() -> void:
	pass


func _process(_delta):
	pass


func build_triad(scale_degree:int, key:Key_Signatures=Key_Signatures.Major, shape:Triad=Triad.Auto, inversion:int=0):
	scale_degree = wrapi(scale_degree, 1, 8) - 1
	inversion = wrapi(inversion, 0, 3)
	var triad = [0, 0, 0]
	triad[0] = signature_dict[key][scale_degree]
	if shape==Triad.Auto:
		shape = scale_degree_dict[key][scale_degree]
	triad[1] = signature_dict[key][scale_degree] + triad_dict[shape][1]
	triad[2] = signature_dict[key][scale_degree] + triad_dict[shape][2]
	if inversion==1:
		triad[0] += 12
	elif inversion==2:
		triad[0] += 12
		triad[1] += 12
	return triad

func build_chord(scale_degree:int, key:Key_Signatures=Key_Signatures.Major, shape:Chord7=Chord7.Auto, inversion:int=0):
	scale_degree = wrapi(scale_degree, 1, 8) - 1
	inversion = wrapi(inversion, 0, 4)
	var chord = [0, 0, 0, 0]
	if shape==Chord7.Auto:
		shape = scale_degree_dict[key][scale_degree]
		match shape:
			Triad.Major:
				shape = Chord7.Major
			Triad.Minor:
				shape = Chord7.Minor
			Triad.Diminished:
				shape = Chord7.Diminished
			Triad.Augmented:
				chord = [0, 4, 8, 10]
				if inversion==1:
					chord[0] += 12
				elif inversion==2:
					chord[0] += 12
					chord[1] += 12
				elif inversion==3:
					chord[0] += 12
					chord[1] += 12
					chord[2] += 12
				return chord
	chord = build_triad(scale_degree+1, key, chord7_dict[shape][0], 0)
	chord.append(signature_dict[key][scale_degree] + chord7_dict[shape][1])
	if inversion==1:
		chord[0] += 12
	elif inversion==2:
		chord[0] += 12
		chord[1] += 12
	elif inversion==3:
		chord[0] += 12
		chord[1] += 12
		chord[2] += 12
	return chord

func make_closed(chord):
	var closed = []
	for i in chord:
		closed.append(i%12)
	return closed


func _on_play_pressed() -> void:
	song = []
	for chord in find_child("SongDisplay").get_children():
		if chord.is_in_group("chord"):
			var temp = [chord.scale_degree, chord.offset, chord.shape, chord.inversion, chord.closed, chord.length]
			song.append(temp)
	var chord
	for i in song:
		chord = build_chord(i[0], current_key, i[2], i[3])
		if i[4]:
			chord = make_closed(chord)
		for v in chord:
			v+=i[1]
			var new_player = note_player.instantiate()
			add_child(new_player)
			new_player.play_note(scale_root+v, float(i[5]*60/bpm * (denominator/4)))
		await get_tree().create_timer(float(i[5]*60/bpm)).timeout


func _on_spin_box_value_changed(value: float) -> void:
	scale_root = value
	match int(value)%12:
		0:
			root_label.text = str(floori(value/12)-2)+"C/B#"
		1:
			root_label.text = str(floori(value/12)-2)+"C#/Db"
		2:
			root_label.text = str(floori(value/12)-2)+"D"
		3:
			root_label.text = str(floori(value/12)-2)+"D#/Eb"
		4:
			root_label.text = str(floori(value/12)-2)+"E/Fb"
		5:
			root_label.text = str(floori(value/12)-2)+"F/E#"
		6:
			root_label.text = str(floori(value/12)-2)+"F#/Gb"
		7:
			root_label.text = str(floori(value/12)-2)+"G"
		8:
			root_label.text = str(floori(value/12)-2)+"G#/Ab"
		9:
			root_label.text = str(floori(value/12)-2)+"A"
		10:
			root_label.text = str(floori(value/12)-2)+"A#/Bb"
		11:
			root_label.text = str(floori(value/12)-2)+"B/Cb"


func _on_bpm_value_changed(value: float) -> void:
	bpm = value


func _on_numerator_value_changed(value: float) -> void:
	numerator = value


func _on_denominator_value_changed(value: float) -> void:
	denominator = value


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			current_key = Key_Signatures.Major
		1:
			current_key = Key_Signatures.Natural_Minor
		2:
			current_key = Key_Signatures.Harmonic_Minor
		3:
			current_key = Key_Signatures.Melodic_Minor
		4:
			current_key = Key_Signatures.Ionian
		5:
			current_key = Key_Signatures.Dorian
		6:
			current_key = Key_Signatures.Phrygian
		7:
			current_key = Key_Signatures.Lydian
		8:
			current_key = Key_Signatures.Mixolydian
		9:
			current_key = Key_Signatures.Aeolian
		10:
			current_key = Key_Signatures.Locrian


func format_track(channel=0):
	var extract = []
	for chord in find_child("SongDisplay").get_children():
		if chord.is_in_group("chord"):
			var temp = [chord.scale_degree, chord.offset, chord.shape, chord.inversion, chord.closed, chord.length]
			extract.append(temp)
	var chord
	var returnable = [channel]
	for i in extract:
		chord = build_chord(i[0], current_key, i[2], i[3])
		if i[4]:
			chord = make_closed(chord)
		for v in range(chord.size()):
			chord[v]+=i[1] + scale_root
		returnable.append([chord, i[5]])
	return returnable


func _on_export_pressed() -> void:
	var temp = []
	var track_counter = -1
	var song = [format_track()]
	for track in song:
		track_counter+=1
		temp.append([track[0]])
		temp[track_counter].append([0, "tempo", bpm])
		temp[track_counter].append([0, "time_signature", numerator, denominator])
		var old_chord = []
		var old_time = 0
		for event in track:
			if event is int:
				continue
			if old_chord.size()!=0:
				temp[track_counter].append([old_time*find_child("MidiConverter").divisions, "note_off", old_chord[0], 0, 0])
				for i in old_chord:
					if i==old_chord[0]:
						continue
					temp[track_counter].append([0, "note_off", i, 0, 0])
			old_chord = event[0]
			old_time = event[1]
			temp[track_counter].append([event[1], "note_on", event[0][0], 100, 0])
			for note in event[0]:
				if note==event[0][0]:
					continue
				temp[track_counter].append([0, "note_on", note, 100, 0])

		temp[track_counter].append([old_time*find_child("MidiConverter").divisions, "note_off", old_chord[0], 0, 0])
		for i in old_chord:
			if i==old_chord[0]:
				continue
			temp[track_counter].append([0, "note_off", i, 0, 0])
	find_child("MidiConverter").make_midi(temp, temp.size(), "user://"+find_child("FileName").text+".mid")
	find_child("ExportPath").text = str(Time.get_time_dict_from_system()["hour"])+":"+str(Time.get_time_dict_from_system()["minute"]) + " - Saved file to: " + str(ProjectSettings.globalize_path("user://"+find_child("FileName").text+".mid"))
	find_child("Dismiss").visible = true


func _on_button_pressed() -> void:
	find_child("ExportPath").text = ""
	find_child("Dismiss").visible = false
