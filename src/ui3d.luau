local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Presets = require(script:WaitForChild("Presets"))

local Ui3d = {}
Ui3d.__index = Ui3d
Ui3d.Presets = Presets

Ui3d.Tuning = {
	Stiffness = 1,
	Wander = 1,
	Swirl = 1,
	Bank = 1,
	Follow = 1,
	Reach = 1,
	Spin = 1,
	Damping = 1,
}

local BindName = "Ui3dPanels"
local Panels = {}
local Bound = false

local Named = {
	Left = Vector3.new(-1, 0, 0),
	Right = Vector3.new(1, 0, 0),
	Up = Vector3.new(0, 1, 0),
	Down = Vector3.new(0, -1, 0),
	Front = Vector3.new(0, 0, -1),
	Back = Vector3.new(0, 0, 1),
}

local Defaults = {
	Name = "Ui3dPanel",
	Size = Vector2.new(4.8, 7.2),
	Thickness = 0.2,
	Distance = 12.5,
	Lateral = 0,
	Vertical = 0,
	Yaw = -10,
	Pitch = 0,
	Roll = 0,
	PixelsPerStud = 100,
	Face = Enum.NormalId.Back,
	Color = Color3.fromRGB(8, 8, 8),
	Transparency = 0.1,
	Preset = "Spin",
	Direction = "Auto",
	Reach = 26,
	AlwaysOnTop = false,
	Interactive = false,
	InputFade = 0.92,
	Float = 1,
	Sway = 7,
	FollowStiffness = 58,
	FollowRatio = 0.66,
	SpinStiffness = 34,
	SpinRatio = 0.6,
	CamBank = 0.9,
	CamDrag = 0.05,
}

local function Merge(Options)
	local Config = {}
	for Key, Value in Defaults do
		Config[Key] = Value
	end
	for Key, Value in Options or {} do
		Config[Key] = Value
	end
	return Config
end

local function Spring(Value, Velocity, Target, Stiffness, Damping, Dt)
	local Steps = math.clamp(math.ceil(Dt * 240), 1, 8)
	local Step = Dt / Steps
	for _ = 1, Steps do
		Velocity += ((Target - Value) * Stiffness - Velocity * Damping) * Step
		Value += Velocity * Step
	end
	return Value, Velocity
end

local StepWidgets

local function StepAll(Delta: number)
	Delta = math.min(Delta, 1 / 20)
	StepWidgets(Delta)
	for Index = #Panels, 1, -1 do
		local Panel = Panels[Index]
		if Panel.Dead then
			table.remove(Panels, Index)
		else
			Panel:Step(Delta)
		end
	end
end

function Ui3d.Bind()
	if Bound then
		return
	end
	Bound = true
	RunService:BindToRenderStep(BindName, Enum.RenderPriority.Last.Value + 2, StepAll)
end

function Ui3d.Unbind()
	if not Bound then
		return
	end
	Bound = false
	RunService:UnbindFromRenderStep(BindName)
end

function Ui3d.All()
	return Panels
end

function Ui3d.CloseAll()
	for _, Panel in Panels do
		Panel:Close()
	end
end

function Ui3d.DestroyAll()
	for Index = #Panels, 1, -1 do
		Panels[Index]:Destroy()
	end
end

function Ui3d.new(Options)
	local self = setmetatable({}, Ui3d)

	self.Config = Merge(Options)
	self.Random = Random.new()
	self.Seed = self.Random:NextNumber() * 512
	self.Dead = false
	self.Shown = false
	self.Live = false
	self.Anchor = nil

	self.Position = Vector3.zero
	self.PositionVelocity = Vector3.zero
	self.Rotation = Vector3.zero
	self.RotationVelocity = Vector3.zero
	self.Scale = 1
	self.ScaleVelocity = 0
	self.Fade = 0
	self.FadeVelocity = 0

	self.World = nil
	self.FollowVelocity = Vector3.zero
	self.SpinVelocity = Vector3.zero

	self:Build()
	self:Reroll()
	self:Snap()

	table.insert(Panels, self)
	Ui3d.Bind()

	return self
end

function Ui3d:Build()
	local Config = self.Config

	local Part = Instance.new("Part")
	Part.Name = Config.Name
	Part.Anchored = true
	Part.CanCollide = false
	Part.CanQuery = Config.Interactive == true
	Part.CanTouch = false
	Part.CastShadow = false
	Part.Locked = true
	Part.Material = Enum.Material.SmoothPlastic
	Part.Color = Config.Color
	Part.Transparency = 1
	Part.Size = Vector3.new(Config.Size.X, Config.Size.Y, Config.Thickness)

	local Gui = Instance.new("SurfaceGui")
	Gui.Name = "Surface"
	Gui.Face = Config.Face
	Gui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	Gui.CanvasSize = Vector2.new(Config.Size.X * Config.PixelsPerStud, Config.Size.Y * Config.PixelsPerStud)
	Gui.LightInfluence = 0
	Gui.AlwaysOnTop = Config.AlwaysOnTop
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	self.Hosted = false
	if Config.Interactive then
		local Player = Players.LocalPlayer
		local PlayerGui = Player and Player:FindFirstChildOfClass("PlayerGui")
		if PlayerGui then
			Gui.Adornee = Part
			Gui.Parent = PlayerGui
			self.Hosted = true
		else
			Gui.Parent = Part
		end
	else
		Gui.Parent = Part
	end

	local Root = Instance.new("CanvasGroup")
	Root.Name = "Root"
	Root.Size = UDim2.fromScale(1, 1)
	Root.BackgroundTransparency = 1
	Root.GroupTransparency = 1
	Root.Parent = Gui

	self.Part = Part
	self.Gui = Gui
	self.Root = Root

	self.CanGate = pcall(function()
		return Root.Interactable
	end)
	self.Interactable = nil
end

function Ui3d:RollDirection(Cone: number): Vector3
	local Value = self.Config.Direction

	if typeof(Value) == "Vector3" and Value.Magnitude > 0.001 then
		return Value.Unit
	end

	local Fixed = Named[tostring(Value)]
	if Fixed then
		local Jitter = Vector3.new(
			self.Random:NextNumber(-0.28, 0.28),
			self.Random:NextNumber(-0.28, 0.28),
			self.Random:NextNumber(-0.28, 0.28)
		)
		return (Fixed + Jitter).Unit
	end

	local Angle = self.Random:NextNumber() * math.pi * 2
	local Height = math.clamp(Cone, -1, 1) * self.Random:NextNumber(0.35, 1)
	local Radius = math.sqrt(math.max(1 - Height * Height, 0.02))
	return Vector3.new(math.cos(Angle) * Radius, Height, math.sin(Angle) * Radius).Unit
end

function Ui3d:Reroll()
	local Entry = Presets.Get(self.Config.Preset)
	local Roll = Presets.Roll(Entry, self.Random)

	Roll.Stiffness *= Ui3d.Tuning.Stiffness
	Roll.Swirl *= Ui3d.Tuning.Swirl
	Roll.Bank *= Ui3d.Tuning.Bank
	Roll.Wander *= Ui3d.Tuning.Wander

	local Spread = Ui3d.Tuning.Reach
	Roll.Reach *= Spread
	Roll.Lateral *= Spread
	Roll.Rise *= Spread
	Roll.Depth *= Spread

	local Turn = Ui3d.Tuning.Spin
	Roll.Yaw *= Turn
	Roll.Pitch *= Turn
	Roll.Roll *= Turn

	Roll.Ratio = math.clamp(Roll.Ratio * Ui3d.Tuning.Damping, 0.12, 1.1)

	Roll.Direction = self:RollDirection(Roll.Cone)
	Roll.Perp = Roll.Direction:Cross(Vector3.yAxis)
	Roll.Perp = Roll.Perp.Magnitude > 0.001 and Roll.Perp.Unit or Vector3.xAxis
	Roll.Phase = self.Random:NextNumber() * 256

	self.Roll = Roll
	return Roll
end

function Ui3d:HiddenPose()
	local Roll = self.Roll
	local Reach = self.Config.Reach

	return {
		Position = Roll.Direction * (Reach * Roll.Reach)
			+ Roll.Perp * (Reach * Roll.Lateral)
			+ Vector3.yAxis * (Reach * Roll.Rise)
			+ Vector3.zAxis * (Reach * Roll.Depth),
		Rotation = Vector3.new(Roll.Pitch, Roll.Yaw, Roll.Roll),
		Scale = Roll.Scale,
		Fade = 0,
	}
end

function Ui3d:Snap()
	local Pose = self:HiddenPose()
	self.Position = Pose.Position
	self.Rotation = Pose.Rotation
	self.Scale = Pose.Scale
	self.Fade = Pose.Fade
	self.PositionVelocity = Vector3.zero
	self.RotationVelocity = Vector3.zero
	self.ScaleVelocity = 0
	self.FadeVelocity = 0
end

function Ui3d:GoalFrame(): CFrame
	local Config = self.Config
	local Camera = workspace.CurrentCamera
	local Base = if self.Anchor then self.Anchor else (Camera and Camera.CFrame or CFrame.identity)

	return Base
		* CFrame.new(Config.Lateral, Config.Vertical, -Config.Distance)
		* CFrame.Angles(math.rad(Config.Pitch), math.rad(Config.Yaw), math.rad(Config.Roll))
end

function Ui3d:StepWorld(Desired: CFrame, Delta: number): CFrame
	local Config = self.Config

	if not self.World or Delta <= 0 then
		self.World = Desired
		self.FollowVelocity = Vector3.zero
		self.SpinVelocity = Vector3.zero
		return self.World
	end

	local Tuning = Ui3d.Tuning.Follow

	local Stiffness = Config.FollowStiffness * Tuning
	local Damping = 2 * Config.FollowRatio * math.sqrt(math.max(Stiffness, 0.01))
	local Position, Velocity =
		Spring(self.World.Position, self.FollowVelocity, Desired.Position, Stiffness, Damping, Delta)
	self.FollowVelocity = Velocity

	local SpinStiffness = Config.SpinStiffness * Tuning
	local SpinDamping = 2 * Config.SpinRatio * math.sqrt(math.max(SpinStiffness, 0.01))

	local Current = self.World.Rotation
	local Axis, Angle = (Current:Inverse() * Desired.Rotation):ToAxisAngle()
	if Angle > math.pi then
		Angle -= math.pi * 2
	end

	local Torque = Vector3.zero
	if Axis.Magnitude > 0.001 and math.abs(Angle) > 1e-5 then
		Torque = Axis.Unit * (Angle * SpinStiffness)
	end

	local Steps = math.clamp(math.ceil(Delta * 240), 1, 8)
	local Step = Delta / Steps
	for _ = 1, Steps do
		self.SpinVelocity += (Torque - self.SpinVelocity * SpinDamping) * Step
	end

	local Speed = self.SpinVelocity.Magnitude
	local Rotated = Current
	if Speed > 1e-5 then
		Rotated = Current * CFrame.fromAxisAngle(self.SpinVelocity.Unit, Speed * Delta)
	end

	self.World = CFrame.new(Position) * Rotated
	return self.World
end

function Ui3d:Step(Delta: number)
	if not self.Live then
		return
	end

	local Config = self.Config
	local Roll = self.Roll
	local Time = os.clock()
	local Seed = self.Seed + Roll.Phase
	local Fbm = Presets.Fbm
	local Anchor = self:GoalFrame()

	local Wander = Config.Float * Roll.Wander
	local DriftPosition = Vector3.new(
		Fbm(Seed, Time, 0.21) * Wander * 1.25,
		Fbm(Seed + 37, Time, 0.17) * Wander * 1.55,
		Fbm(Seed + 71, Time, 0.13) * Wander * 0.7
	)
	local DriftRotation = Vector3.new(
		Fbm(Seed + 101, Time, 0.15) * Wander * Config.Sway * 1.5,
		Fbm(Seed + 149, Time, 0.11) * Wander * Config.Sway * 2.1,
		Fbm(Seed + 193, Time, 0.19) * Wander * Config.Sway * 2.6
	)

	local TargetPosition, TargetRotation, TargetScale, TargetFade

	if self.Shown then
		TargetPosition = DriftPosition
		TargetRotation = DriftRotation
		TargetScale = 1 + Fbm(Seed + 233, Time, 0.09) * 0.03 * Wander
		TargetFade = 1
	else
		local Pose = self:HiddenPose()
		TargetPosition = Pose.Position + DriftPosition
		TargetRotation = Pose.Rotation + DriftRotation
		TargetScale = Pose.Scale
		TargetFade = 0
	end

	local Error = TargetPosition - self.Position
	local Distance = Error.Magnitude
	local Travel = math.clamp(Distance / math.max(Config.Reach, 1), 0, 1)

	if Distance > 0.005 then
		local Curl = math.rad(Roll.Swirl) * Travel
		local Axis = Roll.Perp:Lerp(Vector3.yAxis, 0.5)
		Axis = Axis.Magnitude > 0.001 and Axis.Unit or Vector3.yAxis
		local Curved = CFrame.fromAxisAngle(Axis, Curl):VectorToWorldSpace(Error)

		local Turbulence = Vector3.new(
			Fbm(Seed + 311, Time, 0.34),
			Fbm(Seed + 353, Time, 0.29),
			Fbm(Seed + 401, Time, 0.41)
		) * (Config.Reach * 0.07 * Roll.Wander * (0.4 + 0.6 * Travel))

		TargetPosition = self.Position + Curved + Turbulence
	end

	local Breathe = 1 + Fbm(Seed + 449, Time, 0.07) * 0.22
	local Stiffness = Roll.Stiffness * Breathe
	local Damping = 2 * Roll.Ratio * math.sqrt(math.max(Stiffness, 0.01))

	self.Position, self.PositionVelocity =
		Spring(self.Position, self.PositionVelocity, TargetPosition, Stiffness, Damping, Delta)

	local Velocity = self.PositionVelocity
	local Reference = self.World or Anchor
	local CamLocal = Reference:VectorToObjectSpace(self.FollowVelocity)
	local CamSpin = Reference:VectorToObjectSpace(self.SpinVelocity)

	TargetRotation = TargetRotation + Vector3.new(
		math.clamp(-Velocity.Y * 0.55 * Roll.Bank, -38, 38),
		math.clamp(-Velocity.X * 0.44 * Roll.Bank, -52, 52),
		math.clamp(Velocity.X * 0.66 * Roll.Bank, -46, 46)
	) + Vector3.new(
		math.clamp(-CamLocal.Y * 0.5 * Config.CamBank - math.deg(CamSpin.X) * 0.16 * Config.CamBank, -26, 26),
		math.clamp(-CamLocal.X * 0.34 * Config.CamBank - math.deg(CamSpin.Y) * 0.2 * Config.CamBank, -34, 34),
		math.clamp(CamLocal.X * 0.55 * Config.CamBank + math.deg(CamSpin.Y) * 0.24 * Config.CamBank, -32, 32)
	)

	local RotStiffness = Stiffness * Roll.Spread
	local RotDamping = 2 * Roll.Ratio * math.sqrt(math.max(RotStiffness, 0.01))
	self.Rotation, self.RotationVelocity =
		Spring(self.Rotation, self.RotationVelocity, TargetRotation, RotStiffness, RotDamping, Delta)

	local ScaleStiffness = Stiffness * 0.62
	self.Scale, self.ScaleVelocity = Spring(
		self.Scale, self.ScaleVelocity, TargetScale,
		ScaleStiffness, 2 * Roll.Ratio * math.sqrt(ScaleStiffness), Delta
	)

	self.Fade, self.FadeVelocity = Spring(
		self.Fade, self.FadeVelocity, TargetFade,
		Roll.Fade, 2 * 0.78 * math.sqrt(Roll.Fade), Delta
	)

	local Drag = -Velocity * (Roll.Lead * 0.014)
		- CamLocal * Config.CamDrag

	local Desired = Anchor
		* CFrame.new(self.Position + Drag)
		* CFrame.Angles(math.rad(self.Rotation.X), math.rad(self.Rotation.Y), math.rad(self.Rotation.Z))

	local Frame = self:StepWorld(Desired, Delta)

	local Visible = math.clamp(self.Fade, 0, 1)
	local Size = math.max(self.Scale, 0.005)

	self.Part.CFrame = Frame
	self.Part.Size = Vector3.new(Config.Size.X * Size, Config.Size.Y * Size, Config.Thickness)
	self.Part.Transparency = 1 - (1 - Config.Transparency) * Visible
	self.Root.GroupTransparency = 1 - Visible

	if self.CanGate then
		local Ready = self.Shown and Visible >= Config.InputFade
		if self.Interactable ~= Ready then
			self.Interactable = Ready
			self.Root.Interactable = Ready
		end
	end

	if not self.Shown and Visible < 0.004 and self.FadeVelocity > -0.05 then
		self.Live = false
		self.Part.Parent = nil
	end
end

function Ui3d:Open(PresetName: string?, DirectionName)
	if PresetName then
		self.Config.Preset = PresetName
	end
	if DirectionName then
		self.Config.Direction = DirectionName
	end

	local WasLive = self.Live
	self:Reroll()
	if not WasLive then
		self.World = nil
		self:Snap()
	end

	self.Shown = true
	self.Live = true
	self.Part.Parent = if self.Config.Interactive then workspace else workspace.CurrentCamera
	self:Step(0)

	return self
end

function Ui3d:Close()
	if not self.Live then
		return self
	end
	self:Reroll()
	self.Shown = false
	return self
end

function Ui3d:Toggle(PresetName: string?, DirectionName)
	if self.Shown then
		return self:Close()
	end
	return self:Open(PresetName, DirectionName)
end

function Ui3d:IsOpen(): boolean
	return self.Shown
end

function Ui3d:Nudge(Impulse: Vector3, Spin: Vector3?)
	self.PositionVelocity += Impulse
	if Spin then
		self.RotationVelocity += Spin
	end
	return self
end

function Ui3d:Anchored(Frame: CFrame?)
	self.Anchor = Frame
	return self
end

function Ui3d:Configure(Options)
	for Key, Value in Options or {} do
		self.Config[Key] = Value
	end
	return self
end

function Ui3d:Destroy()
	self.Dead = true
	if self.Hosted and self.Gui then
		self.Gui:Destroy()
	end
	self.Gui = nil
	if self.Part then
		self.Part:Destroy()
		self.Part = nil
	end
	local Index = table.find(Panels, self)
	if Index then
		table.remove(Panels, Index)
	end
end

local Interact = {}
Interact.__index = Interact

local Widgets = {}

function StepWidgets(Delta: number)
	for Index = #Widgets, 1, -1 do
		local Widget = Widgets[Index]
		if Widget.Dead then
			table.remove(Widgets, Index)
		else
			Widget:Step(Delta)
		end
	end
end

function Ui3d.Interact(Object: GuiObject, PresetName: string?, Overrides)
	local self = setmetatable({}, Interact)

	self.Object = Object
	self.Entry = Presets.GetInteract(PresetName)
	self.Config = Overrides or {}
	self.Dead = false
	self.Enabled = true
	self.Hovering = false
	self.Pressing = false
	self.Connections = {}

	self.Scale = 1
	self.ScaleVelocity = 0
	self.Offset = Vector2.zero
	self.OffsetVelocity = Vector2.zero
	self.Rotation = 0
	self.RotationVelocity = 0
	self.Tint = 0
	self.TintVelocity = 0

	local Scaler = Object:FindFirstChildOfClass("UIScale")
	if not Scaler then
		Scaler = Instance.new("UIScale")
		Scaler.Parent = Object
	end
	self.Scaler = Scaler

	self.BasePosition = Object.Position
	self.BaseRotation = Object.Rotation
	self.BaseColor = Object.BackgroundColor3
	self.Stroke = Object:FindFirstChildOfClass("UIStroke")
	self.BaseStroke = self.Stroke and self.Stroke.Thickness or 0

	local Parent = Object.Parent
	self.Layouted = Parent ~= nil and Parent:FindFirstChildWhichIsA("UILayout") ~= nil

	self:Connect()
	table.insert(Widgets, self)
	Ui3d.Bind()

	return self
end

function Interact:Connect()
	local Object = self.Object

	table.insert(self.Connections, Object.MouseEnter:Connect(function()
		if self.Enabled then
			self.Hovering = true
		end
	end))

	table.insert(self.Connections, Object.MouseLeave:Connect(function()
		self.Hovering = false
		self.Pressing = false
	end))

	table.insert(self.Connections, Object.InputBegan:Connect(function(Input)
		if not self.Enabled then
			return
		end
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			self.Pressing = true
			self:Impulse()
		end
	end))

	table.insert(self.Connections, Object.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			self.Pressing = false
		end
	end))
end

function Interact:Impulse()
	local Kick = self.Entry.Kick
	self.ScaleVelocity += (Kick.Scale or 0)
	self.RotationVelocity += (Kick.Rotation or 0)
	self.OffsetVelocity += (Kick.Offset or Vector2.zero)
	return self
end

function Interact:State()
	if not self.Enabled then
		return self.Entry.Disabled
	elseif self.Pressing then
		return self.Entry.Press
	elseif self.Hovering then
		return self.Entry.Hover
	end
	return self.Entry.Idle
end

function Interact:Step(Delta: number)
	local Object = self.Object
	if not Object.Parent then
		self:Destroy()
		return
	end

	local Entry = self.Entry
	local Target = self:State()

	local function Pull(Value, Velocity, Goal, Channel)
		local Stiffness = Channel.Stiffness * Ui3d.Tuning.Stiffness
		local Damping = 2 * Channel.Ratio * math.sqrt(math.max(Stiffness, 0.01))
		return Spring(Value, Velocity, Goal, Stiffness, Damping, Delta)
	end

	self.Scale, self.ScaleVelocity = Pull(self.Scale, self.ScaleVelocity, Target.Scale, Entry.Scale)
	self.Offset, self.OffsetVelocity = Pull(self.Offset, self.OffsetVelocity, Target.Offset, Entry.Offset)
	self.Rotation, self.RotationVelocity = Pull(self.Rotation, self.RotationVelocity, Target.Rotation, Entry.Rotation)
	self.Tint, self.TintVelocity = Pull(self.Tint, self.TintVelocity, Target.Tint, Entry.Tint)

	self.Scaler.Scale = math.max(self.Scale, 0.02)
	Object.Rotation = self.BaseRotation + self.Rotation

	if not self.Layouted then
		local Base = self.BasePosition
		Object.Position = UDim2.new(
			Base.X.Scale, Base.X.Offset + self.Offset.X,
			Base.Y.Scale, Base.Y.Offset + self.Offset.Y
		)
	end

	local Blend = self.Tint
	if Blend >= 0 then
		Object.BackgroundColor3 = self.BaseColor:Lerp(Entry.Highlight, math.clamp(Blend, 0, 1))
	else
		Object.BackgroundColor3 = self.BaseColor:Lerp(Entry.Shadow, math.clamp(-Blend, 0, 1))
	end

	if self.Stroke then
		self.Stroke.Thickness = self.BaseStroke * (1 + math.clamp(Blend, 0, 1) * 0.9)
	end
end

function Interact:SetEnabled(State: boolean)
	self.Enabled = State ~= false
	if not self.Enabled then
		self.Hovering = false
		self.Pressing = false
	end
	return self
end

function Interact:SetPreset(Name: string)
	self.Entry = Presets.GetInteract(Name)
	return self
end

function Interact:Destroy()
	self.Dead = true
	for _, Connection in self.Connections do
		Connection:Disconnect()
	end
	table.clear(self.Connections)
end

function Ui3d.InteractAll(Container: Instance, PresetName: string?, Filter)
	local Made = {}
	for _, Child in Container:GetDescendants() do
		if Child:IsA("GuiObject") and (not Filter or Filter(Child)) then
			table.insert(Made, Ui3d.Interact(Child, PresetName))
		end
	end
	return Made
end


return Ui3d
