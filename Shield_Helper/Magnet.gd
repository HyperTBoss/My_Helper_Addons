extends Child_State

onready var Collect_Rings = $Detect_Rings
var can_collect_rings:bool = false
var magnet_parent

func enter(host):
	magnet_parent = host.parent
	print("Mag Enter")
	Collect_Rings.set_deferred("monitoring", true)
	Collect_Rings.set_deferred("monitorable", true)
	host.Shield_Sprite_Partical.set_emitting(true)
	return

func step(host, delta: float):
	return

func exit(host):
	Collect_Rings.set_deferred("monitoring", false)
	Collect_Rings.set_deferred("monitorable", false)
	host.Shield_Sprite_Partical.set_emitting(false)
	return


func _on_Detect_Rings_body_entered(body):
	can_collect_rings = true
	print("Got you")
	if body is Ring:
		body.HandleRing = 0
		if body.get_mode() == RigidBody2D.MODE_STATIC:
			#body.set_mode(RigidBody2D.MODE_RIGID)
			body.call_deferred("set_mode", RigidBody2D.MODE_RIGID)
		get_tree().create_timer(0.2).connect("timeout", self, "give_reference", [body]);

func give_reference(body):
	if body.get_mode() == RigidBody2D.MODE_RIGID:
		if magnet_parent != null:
			body.entity_reference = magnet_parent
	pass # Replace with function body.
