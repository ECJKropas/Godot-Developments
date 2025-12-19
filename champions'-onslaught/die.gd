extends Node

signal dead_process_finished

var dead_start_time:float =-1
var timer:float = 0.0
var dead:bool = false

var subject
var hidden_time

func die_init(subject0,hidden_time0):
	subject=subject0
	hidden_time=hidden_time0
	dead_start_time=timer
	dead=true

func _process(delta: float) -> void:
	timer+=delta
	if dead and  type_string(typeof(subject))!="previously freed":
		if dead_start_time == -1:
			dead_start_time=timer
		else:
			if dead_start_time+hidden_time<timer:
				subject.visible=false
				subject.queue_free()
				dead_process_finished.emit()
				self.queue_free()
			else:
				subject.modulate.a8=(dead_start_time+hidden_time-timer)/hidden_time*255
