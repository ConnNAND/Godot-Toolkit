extends HBoxContainer
var chord = preload("res://addons/DogsToolkit/musiq/chord.tscn")

func _on_new_chord_pressed() -> void:
	var temp = get_child_count()
	add_child(chord.instantiate())
	move_child($NewChord, temp)
	get_child(temp-1).update_index()
