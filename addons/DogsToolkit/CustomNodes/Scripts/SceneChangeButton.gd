extends Button
class_name SceneChangeButton

@export var next_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(change_scene)


func change_scene():
	get_tree().change_scene_to_packed(next_scene)
