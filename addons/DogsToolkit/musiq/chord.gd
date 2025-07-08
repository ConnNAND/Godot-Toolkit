extends MarginContainer

enum Chord7 {Major, Minor, Dominant, Half_Diminished, Diminished, Auto}

var scale_degree:int = 1
var offset:int = 0
var shape:Chord7 = Chord7.Major
var inversion:int = 0
var closed:bool = false
var length:float = 4.0

var removed = false


func _ready() -> void:
	match find_child("ShapeButton").selected:
		0:		#auto
			shape = Chord7.Auto
		1:		#major
			shape = Chord7.Major
		2:		#dominant
			shape = Chord7.Dominant
		3:		#minor
			shape = Chord7.Minor
		4:		#half-diminished
			shape = Chord7.Half_Diminished
		5:		#diminished
			shape = Chord7.Diminished
	inversion = find_child("InversionButton").selected
	closed = find_child("ClosedToggle").button_pressed
	offset = find_child("Offset").value
	scale_degree = int(find_child("ScaleDegree").text)
	length = int(find_child("Length").text)
	find_child("Index").text = "idx:"+str(get_index())


func _on_scale_degree_text_changed(new_text: String) -> void:
	scale_degree = int(new_text)


func _on_offset_value_changed(value: float) -> void:
	offset = value


func _on_shape_button_item_selected(index: int) -> void:
	match index:
		0:		#auto
			shape = Chord7.Auto
		1:		#major
			shape = Chord7.Major
		2:		#dominant
			shape = Chord7.Dominant
		3:		#minor
			shape = Chord7.Minor
		4:		#half-diminished
			shape = Chord7.Half_Diminished
		5:		#diminished
			shape = Chord7.Diminished


func _on_inversion_button_item_selected(index: int) -> void:
	inversion = index


func _on_option_button_toggled(toggled_on: bool) -> void:
	closed = toggled_on


func _on_length_text_changed(new_text: String) -> void:
	length = int(new_text)

func update_index():
	if removed:
		find_child("Index").text = "idx:"+str(get_index()-1)
	else:
		find_child("Index").text = "idx:"+str(get_index())


func _on_remove_pressed() -> void:
	for i in get_tree().get_nodes_in_group("chord"):
		i.removed = true
		i.update_index()
	queue_free()


func _on_left_pressed() -> void:
	var temp = get_index()
	if temp > 0:
		get_parent().move_child(get_parent().get_child(temp), temp-1)
		get_parent().get_child(temp).update_index()
	find_child("Index").text = "idx:"+str(get_index())


func _on_right_pressed() -> void:
	var temp = get_index()
	if temp < get_parent().get_child_count()-2:
		get_parent().move_child(get_parent().get_child(temp), temp+1)
		get_parent().get_child(temp).update_index()
	find_child("Index").text = "idx:"+str(get_index())
