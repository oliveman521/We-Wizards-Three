extends ProgressBar



var in_progress_level: LevelData:
	get:
		return GameManager.in_progress_level as LevelData

var start_time: float

func _ready() -> void:
	max_value = in_progress_level.remaining_level_length_seconds
	start_time = Time.get_ticks_msec() / 1000.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_since_level_start: float = (Time.get_ticks_msec() / 1000.0) - start_time
	value = time_since_level_start
