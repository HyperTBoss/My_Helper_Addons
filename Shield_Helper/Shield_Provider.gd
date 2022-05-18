tool
extends Node2D

signal Emit_Shield_Activation
signal Emit_Shield_Deactivation
#onready var host = get_parent()

onready var item_box_constants = GlobalConstants.ItemBox_Constents.new().normal_item_box_shields
onready var item_box_constants_names = item_box_constants.keys()
onready var Shield_Sprite = $Shield_VFX/Shield
onready var Shield_Sprite_Animation = $Shield_VFX/Shield/AnimationPlayer
onready var Shield_Sprite_Partical = $Shield_VFX/Shield/Particals
onready var State_Machine_Node = $Shield_Provider_Partical_States
export(int, "Shield_Normal", "Magnet", "Invincability", "Speed_Shoes", 
		"Single_Shot", "Homing_Attack", "Fire", "Bubble", 
		"Rock", "Hook", "None") var Shield_Default
export(NodePath) var ParentReference

export(float) var Invincable_Duration = 5
export(float) var Speed_Shoes_Duration = 10
export(bool) var Environmental_Effects = true
export(float) var Enemy_Interaction =  true
export(Dictionary) var BlackList_Shield_Type = { #For now. Hard coding it is the only solution
	"Shield_Normal": false,
	"Magnet": false,
	"Invincability": false,
	"Speed_Shoes": false,
	"Single_Shot": false,
	"Homing_Attack": false,
	"Fire": false,
	"Bubble": false,
	"Rock": false,
	"Hook": false,
	"None": false
}
var parent

func _ready():
	emit_signal("Emit_Shield_Activation", [Shield_Default, item_box_constants_names[Shield_Default] if Shield_Default <= item_box_constants_names.size()-1 else "None"])
	parent = get_node(ParentReference)
	change_shield(Shield_Default)
	pass

func process(_delta):
	property_list_changed_notify()
	if Engine.editor_hint:
		if item_box_constants_names != null:
			if Shield_Default > item_box_constants_names.size()-1:
				Shield_Sprite.visible = false
			else:
				Shield_Sprite.visible = true
				Shield_Sprite_Animation.play(item_box_constants_names[Shield_Default])

func change_shield(ShieldType:int)->void:
	#print(State_Machine_Node.has_method("activate_state_machine"))
	Shield_Default = ShieldType
	printt("Attempted Shield Change", item_box_constants_names[Shield_Default])
	change_shield_vfx(Shield_Default)
	emit_signal("Emit_Shield_Activation", [Shield_Default, item_box_constants_names[Shield_Default] if Shield_Default <= item_box_constants_names.size()-1 else "None"])
	State_Machine_Node.change_state(item_box_constants_names[Shield_Default])
	pass
func deactivate_shield()-> void:
	if State_Machine_Node.current_state != item_box_constants_names[item_box_constants_names.size()-1]:
		State_Machine_Node.change_state(item_box_constants_names[item_box_constants_names.size()-1])
		State_Machine_Node.deactivate_state_machine()
	pass

func change_shield_vfx(ShieldType:int)->void:
	if ShieldType > item_box_constants_names.size()-1:
		Shield_Sprite.visible = false
	else:
		Shield_Sprite.visible = true
		Shield_Sprite_Animation.stop(true)
		Shield_Sprite_Animation.play(item_box_constants_names[ShieldType])
	pass
