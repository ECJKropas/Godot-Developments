extends Node2D

func _ready():
	# 创建录音总线并添加AudioEffectRecord
	if not AudioServer.get_bus_index("RecordBus") >= 0:
		print("No bus, Creating bus.")
		var bus_idx = AudioServer.bus_count
		AudioServer.add_bus(bus_idx)
		AudioServer.set_bus_name(bus_idx, "RecordBus")
		AudioServer.add_bus_effect(bus_idx, AudioEffectRecord.new())
		AudioServer.set_bus_send(bus_idx, "Master")  # 路由到主输出
		
var _record_effect: AudioEffectRecord

func _start_recording():
	var bus_idx = AudioServer.get_bus_index("RecordBus")
	_record_effect = AudioServer.get_bus_effect(bus_idx, 0)
	_record_effect.set_recording_active(true)  # 开始录音
	$VBoxContainer/StatusLabel.text = "Recording..."
	$VBoxContainer/RecordButton.text = "Stop Recording"
	$VBoxContainer/PlayButton.disabled = true

func _stop_recording():
	_record_effect.set_recording_active(false)
	var recording = _record_effect.get_recording()  # 获取音频流
	$VBoxContainer/StatusLabel.text = "Finished Recording"
	$VBoxContainer/RecordButton.text = "Start Recording"
	$VBoxContainer/PlayButton.disabled = false
	return recording

func _play_recording(recording: AudioStreamWAV):
	$AudioStreamPlayer.stream = recording
	$AudioStreamPlayer.play()
	$VBoxContainer/StatusLabel.text = "Playing"

# 麦克风电平实时检测（在_process中）
func _process(_delta):
	var peak = AudioServer.get_bus_peak_volume_left_db(
		AudioServer.get_bus_index("RecordBus"), 0
	)
	$VBoxContainer/MicLevelBar.value = lerp($VBoxContainer/MicLevelBar.value, peak, 0.1)

var _current_recording

func _on_record_button_pressed():
	if _record_effect and _record_effect.is_recording_active():
		var recording = _stop_recording()
		_current_recording = recording
		_current_recording.save_to_wav("user://test_recording.wav")
	else:
		_start_recording()

func _on_playback_button_pressed():
	if _current_recording:
		_play_recording(_current_recording)
