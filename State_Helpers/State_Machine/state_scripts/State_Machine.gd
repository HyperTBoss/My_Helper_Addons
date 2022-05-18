extends Node

class_name State_Machine

signal traverse_state_signal_finshed
signal traverse_state_signal_start
signal traverse_state_signal_in_step

#### Varable to collect all child states and populate each one with keys and a node path reference.
onready var states = _populate_states({})

#### Get parent or get a reference to said parent.
export(NodePath) var ParentReference
export(Array) var Custome_Names

export(bool) var Enable_State_Debug = false
export(int, "State_Machine", "Traverse_Branch", "Traverse_Branch_Auto") var Machine_Type = 0
onready var host = get_parent() if get_parent() != null else get_node_or_null(ParentReference)

var state_names:Array setget , get_state_names

var host_has_physics_step : bool = false
var host_has_process : bool = false

var state_machine_actived : bool = false
var state_machine_active : bool = false
var node_reference_name : String


export(String) var current_state
var previous_state = null

func _ready():
	if host == null:
		set_physics_process(false)
		set_process(false)
		push_warning("There's no parent or reference for this State_Machine")
	else:
		if host.has_method("process"):
			host_has_process = true
		if host.has_method("physics_step"):
			host_has_physics_step = true
		set_physics_process(true)
		set_process(true)
		state_machine_actived = true


func _populate_states(InitialDict) -> Dictionary:
	var get_childern_amount = get_child_count()
	var flag_no_custome_names:bool
	
	if get_childern_amount == 0:
		push_warning("There's no children in the state machine")
		return {}
	
	get_childern_amount -= 1
	
	var get_children = get_children()
	
	var idx:int = 0
	if Custome_Names.size() == 0:
		flag_no_custome_names = true
	var child_name:String
	
	for child in get_children:
		if child is Child_State:
			state_names.append(child.get_name())
			child_name = child.get_name() if flag_no_custome_names == true else ( Custome_Names[idx] if idx < get_childern_amount else child.get_name() )
			InitialDict[child.get_name()] = get_node(child.get_name())
		else:
			push_warning("Child doesn't have  the class_name Child_State")
		idx+=1
		pass
	
	flag_no_custome_names = false
	idx = 0
	return InitialDict

func _process(delta):
	if host.has_method("process"):
		host.process(delta)
	
	if !host.has_method("physics_step"):
		var state_name = states[current_state].step(host, delta)
		
		if state_name:
			change_state(state_name)

func _physics_process(delta):
	if host.has_method("physics_step"):
		host.physics_step(delta)

	var state_name = states[current_state].step(host, delta)
	
	if state_name:
		change_state(state_name)

func change_state(state_name):
	if state_name == current_state:
		return
	if Enable_State_Debug:
		states[current_state].exit(host)
		print("Exited: " + current_state)
		previous_state = current_state
		current_state = state_name
		states[current_state].enter(host)
		print("Entered: " + current_state)
	else:
		states[current_state].exit(host)
		previous_state = current_state
		current_state = state_name
		states[current_state].enter(host)

func deactivate_state_machine()->void:
	if host_has_physics_step:
		set_physics_process(false)
	if host_has_process:
		set_process(false)

func activate_state_machine()->void:
	if host_has_physics_step:
		set_physics_process(true)
	if host_has_process:
		set_process(true)

#Traverse_Branch Functions
func traverse_to_next_state():
	pass

#Utility
func get_state_names():
	return state_names if state_names!= null else push_warning("You can only access this in run_time")
	pass
