extends ProgressBar

func set_health(health:int,max_health=100) -> void:
	self.value=min(max(int(100*health/max_health),0),100)
	pass
