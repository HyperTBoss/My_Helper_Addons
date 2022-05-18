extends Camera2D

class_name Gompo_Camera2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var TimeItems = [
	$"UI/Main-Items/TimeRectReference/TimeContainer/HH/HH",
	$"UI/Main-Items/TimeRectReference/TimeContainer/HH/HH2",
	$"UI/Main-Items/TimeRectReference/TimeContainer/MM/MM",
	$"UI/Main-Items/TimeRectReference/TimeContainer/MM/MM2",
	$"UI/Main-Items/TimeRectReference/TimeContainer/SS/SS",
	$"UI/Main-Items/TimeRectReference/TimeContainer/SS/SS2",
	$"UI/Main-Items/TimeRectReference/TimeContainer/MS/MS",
	$"UI/Main-Items/TimeRectReference/TimeContainer/MS/MS2",
]
onready var RingCounter = [
	$"UI/Main-Items/RingRectReference/RingContainer/RingCounter/U",
	$"UI/Main-Items/RingRectReference/RingContainer/RingCounter/T",
	$"UI/Main-Items/RingRectReference/RingContainer/RingCounter/H"
] 
onready var ChargeItems = $"UI/Main-Items/ChargeReferenceRect/ChargeProgressBar"


export(float) var CameraPullBackStrength = 1
export(float) var CameraLookHoriStrength = 1
export(NodePath) onready var host_path
export(float) var TimeToLookUp = 1.5
export(float) var TimeToLookDown = 1.5

var LookUpCamera : float
var LookDownCamera : float
var Index = 0
var SpedBreakLimit : float
var smoothCameraValue : float
var CameraOffsetX : Vector2
var CameraOffsetY : Vector2
var ParentTOP : float
var Gsp : float
var ParentDirection : int
var ParentVelocityY : float
var ParentVelocityNormilized : Vector2
var PastGsp = null
var PastParentDirection = null
var gravity_vector : Vector2

var Time:float = 0.0
var Time_Ms:int = 0.0
var Time_Sec:int = 0.0
var Time_Min:int = 0.0
var Time_Hour:int = 0.0

var host

# Called when the node enters the scene tree for the first time.
func _ready():
	host = get_node(host_path)
	if host is PlayerPhysics:
		SpedBreakLimit = host.speedBreakGspActivationLimit # This will be converted to charge soon.
		ChargeItems.max_value = SpedBreakLimit
		ParentTOP = host.TOP
		CameraOffsetX = Vector2.ZERO
		LookUpCamera = TimeToLookUp
		LookDownCamera = TimeToLookDown

func set_child_camera(child_camera:Gompo_Camera2D_Child):
	pass

func _process(delta):
	if host is PlayerPhysics:
		var RingCountInt = host.InnerPlayerState["CurrentLevelState"]["Rings"] if host != null else 0
		var RingCountString = String(RingCountInt)
		
		gravity_vector = Physics2DServer.area_get_param(get_viewport().find_world_2d().get_space(),Physics2DServer.AREA_PARAM_GRAVITY_VECTOR)
		#print(rad2deg(Vector2(0,1).angle_to(gravity_vector)))
		self.rotation_degrees = rad2deg(Vector2(0, 1).angle_to(gravity_vector))
		if  host != null: #A bit jumpy. But I'll fix it when the time comes.
			if host.is_looking_down:
				LookDownCamera -= delta
				if LookDownCamera <= 0:
					self.set_global_position(lerp(self.get_global_position(), self.get_global_position() + Vector2.DOWN*500, 0.1)) #---
			elif host.is_looking_up:
				LookUpCamera -= delta
				if LookUpCamera <= 0:
					self.set_global_position(lerp(self.get_global_position(), self.get_global_position() + Vector2.UP*500, 0.1)) #---
			else:
				self.set_global_position(lerp( self.get_global_position(), host.get_global_position(), 0.1))
				LookUpCamera = TimeToLookUp
				LookDownCamera = TimeToLookDown
	
		#printt(LookDownCamera, LookUpCamera)
		#printt(host.is_looking_down, host.is_looking_up, LookUpCamera, LookDownCamera)
		
		#Changing all of this to mimic what counters do.
		#I just used this as a placeholder for now. Since I had no clue on how to construct a counter at the time.
		ring_count(RingCountInt, RingCountString)
	

#This will handle all of the camera movement. 
#We will have 3 or more modes.
# GroundAndAir Mode - Camera Pulls behind the player, depdent on Vector Speed and GSP.
# Wall MOde - Same as ground mode. But has the ability to transition to Sudo 3D at will. And will have a defualt offset from the player.
# Boss Static Mode - A static camera that will allow bosses to call and manipulate the camera. And will allow the player to more freely manipulate the camera as well.
# Boss Dynamic Run Mode - Soly focused on the Player.

func _physics_process(delta):
	delta_to_time(delta)
	
	if host != null:
		follow_entity(host)
	
	if host is PlayerPhysics:
		Gsp = host.gsp if host.is_grounded else host.velocity.x

		ParentVelocityY = host.velocity.y if host != null else 0
		ParentVelocityNormilized = host.velocity.normalized() if host != null else Vector2.ZERO
		ParentDirection = host.character.scale.x if host != null else 0
		var SmoothLeftX = Vector2(ParentVelocityNormilized.x * smoothCamera(-ParentTOP*3, ParentTOP*3, Gsp), 0) #Handling Y Smoothing (ParentVelocityNormilized.y * smoothCamera(-1, 1, ParentVelocityY))
		var SmoothRightX = Vector2(-(ParentVelocityNormilized.x * smoothCamera(-ParentTOP*3, ParentTOP*3, Gsp)), 0)
		CameraOffsetX = lerpToVecZero_Transition(SmoothLeftX*CameraPullBackStrength, SmoothRightX*CameraPullBackStrength, ParentTOP, Gsp, 0.05)
		self.set_offset(CameraOffsetX)
		ChargeItems.value = abs(Gsp)
	pass

func follow_entity(host):
	self.global_position = lerp(self.global_position, host.global_position, 0.65)
	pass

func ring_count(RingCountInt : int, RingCountString:String): #It'll do
	if RingCountInt > 999:
		RingCounter[0].frame = 9
		RingCounter[1].frame = 9
		RingCounter[2].frame = 9
		return
	
	if RingCountInt < 10:
		RingCounter[0].frame = int(RingCountString.substr(0,1))
	elif RingCountInt < 100:
		RingCounter[0].frame = int(RingCountString.substr(1,1))
		RingCounter[1].frame = int(RingCountString.substr(0,1))
	elif RingCountInt < 999:
		RingCounter[0].frame = int(RingCountString.substr(2,1))
		RingCounter[1].frame = int(RingCountString.substr(1,1))
		RingCounter[2].frame =int(RingCountString.substr(0,1))
	pass

func time_count():
	pass

func smoothCamera(maxVal, minVal, Change):
	var ModifiedValue = smoothstep(maxVal, minVal, Change)
	if ModifiedValue == 0.5:
		ModifiedValue = 0
	elif ModifiedValue > 0.5:
		ModifiedValue = smoothstep(0.5, 1, ModifiedValue) #Range 0 to 1
	elif ModifiedValue < 0.5:
		ModifiedValue = -smoothstep(0.5, 0, ModifiedValue) #Range -1 to 0
	
	return ModifiedValue*100

func lerpToVecZero_Transition(SmoothInPos, SmoothInNeg, Limit, ActiveValue, Strength):
	#print(CameraOffsetX, SmoothLeftIn, SmoothRightIn, Gsp)
	
	if ActiveValue > Limit:
		#print("here")
		return lerp(CameraOffsetX, SmoothInPos, Strength)
		#print(CameraOffsetX)
	elif ActiveValue < -Limit:
		return lerp(CameraOffsetX, SmoothInNeg, Strength) 
		#print(CameraOffsetX)
	else:
		return lerp(CameraOffsetX,  Vector2.ZERO, Strength) 
	pass

func delta_to_time(delta)->void: #It's functional
	if Time_Hour >= 99:
		return

	Time+=delta
	Time_Ms = fmod(Time,1)*100
	Time_Sec = fmod(Time,60)
	Time_Min = fmod(Time, 3600) / 60
	Time_Hour = fmod(Time, 3600000) / 3600
	
	var idx:int = 7
	for time_counters in TimeItems:
		match idx:
			7:
				time_counters.frame = Time_Ms/10%10
			6:
				time_counters.frame = Time_Ms%10
			5:
				time_counters.frame = Time_Sec/10%10
			4:
				time_counters.frame = Time_Sec%10
			3:
				time_counters.frame = Time_Min/10%10
			2:
				time_counters.frame = Time_Min%10
			1:
				time_counters.frame = Time_Hour/10%10
			0:
				time_counters.frame = Time_Hour%10
		idx-=1
		pass
	#printt(Time, Time_Ms, Time_Sec, Time_Min, Time_Hour)
	pass
