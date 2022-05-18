extends Child_State

signal Shield_End

var invince_timer
 
func enter(host):
	invince_timer = 5

func step(host, delta: float):
	invince_timer -= delta
	if invince_timer < 0:
		return 'None'

func exit(host):
	invince_timer = host.Invincable_Duration
