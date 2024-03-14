extends Node


func play_sound(sound_node: AudioStreamPlayer2D, randomize_pitch: float = 0) -> void:
	var new_node: AudioStreamPlayer2D = sound_node.duplicate() as AudioStreamPlayer2D
	add_child(new_node)
	new_node.pitch_scale += randf_range(-randomize_pitch, randomize_pitch)
	new_node.play()
	new_node.finished.connect(new_node.queue_free)
