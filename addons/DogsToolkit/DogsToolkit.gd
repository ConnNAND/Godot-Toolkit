@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("SpatializedAudioStreamPlayer3D", "AudioStreamPlayer3D", preload("CustomNodes/Scripts/SpatializedAudioStreamPlayer3D.gd"), preload("CustomNodes/Icons/AudioStreamPlayer3D.svg"))
	add_custom_type("SpatializedCamera3D", "Camera3D", preload("CustomNodes/Scripts/SpatializedCamera3D.gd"), preload("CustomNodes/Icons/Camera3D.svg"))
	add_custom_type("SceneChangeButton", "Button", preload("CustomNodes/Scripts/SceneChangeButton.gd"), preload("CustomNodes/Icons/Button.svg"))
	add_custom_type("BaseMenuSystem", "Control", preload("CustomNodes/Scripts/BaseMenu.gd"), preload("CustomNodes/Icons/Window.svg"))
	add_custom_type("FollowerArm3D", "SpringArm3D", preload("CustomNodes/Scripts/FollowerArm3D.gd"), preload("CustomNodes/Icons/SpringArm3D.svg"))
	add_custom_type("VirtualEye3D", "Node3D", preload("CustomNodes/Scripts/VirtualEye.gd"), preload("CustomNodes/Icons/Eye.svg"))
	add_custom_type("VirtualMouth3D", "Node3D", preload("CustomNodes/Scripts/VirtualMouth.gd"), preload("CustomNodes/Icons/Mouth.svg"))
	add_custom_type("DialogueManager", "Label", preload("CustomNodes/Scripts/dialogueManager.gd"), preload("CustomNodes/Icons/Dialogue.svg"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("SpatializedAudioStreamPlayer3D")
	remove_custom_type("SpatializedCamera3D")
	remove_custom_type("SceneChangeButton")
	remove_custom_type("BaseMenuSystem")
	remove_custom_type("FollowerArm3D")
	remove_custom_type("VirtualEye3D")
	remove_custom_type("VirtualMouth3D")
	remove_custom_type("DialogueManager")
