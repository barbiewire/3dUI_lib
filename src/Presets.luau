local Presets = {}

local Base = {
	Reach = {0.44, 0.69},
	Rise = {-0.12, 0.25},
	Lateral = {-0.25, 0.25},
	Depth = {-0.08, 0.19},
	Yaw = {-36.00, 36.00},
	Pitch = {-13.20, 13.20},
	Roll = {-15.60, 15.60},
	Scale = {0.84, 1},
	Swirl = {22.00, 63.25},
	Bank = {0.4, 0.95},
	Lead = {0.2, 0.7},
	Stiffness = {59.40, 91.80},
	Ratio = {0.50, 0.67},
	Spread = {0.32, 0.72},
	Wander = {0.33, 0.66},
	Fade = {80, 150},
	Cone = {-0.55, 0.8},
}

local Library = {
	Spin = {
		Reach = {0.52, 0.77},
		Yaw = {-172.00, 172.00},
		Roll = {-31.20, 31.20},
		Scale = {0.7, 0.92},
		Swirl = {52.25, 107.25},
		Bank = {0.65, 1.15},
		Stiffness = {45.90, 78.30},
		Ratio = {0.48, 0.64},
		Wander = {0.44, 0.83},
	},
	Slide = {
		Reach = {0.41, 0.61},
		Yaw = {-23.20, 23.20},
		Pitch = {-7.20, 7.20},
		Swirl = {16.50, 44.00},
		Stiffness = {78.30, 116.10},
		Ratio = {0.53, 0.68},
		Wander = {0.22, 0.50},
		Cone = {-0.25, 0.3},
	},
	Flip = {
		Reach = {0.22, 0.41},
		Pitch = {-81.00, 81.00},
		Yaw = {-18.40, 18.40},
		Scale = {0.78, 0.96},
		Swirl = {24.75, 60.50},
		Stiffness = {54.00, 89.10},
		Ratio = {0.45, 0.61},
	},
	Swing = {
		Reach = {0.47, 0.69},
		Yaw = {-64.00, 64.00},
		Roll = {-12.00, 12.00},
		Swirl = {38.50, 82.50},
		Bank = {0.8, 1.3},
		Lead = {0.4, 0.9},
		Stiffness = {40.50, 70.20},
		Ratio = {0.48, 0.64},
		Cone = {-0.35, 0.45},
	},
	Rise = {
		Reach = {0.28, 0.50},
		Rise = {-0.90, -0.54},
		Pitch = {-48.00, -21.00},
		Swirl = {13.75, 41.25},
		Stiffness = {62.10, 97.20},
		Ratio = {0.51, 0.67},
		Cone = {-1, -0.6},
	},
	Fold = {
		Reach = {0.08, 0.28},
		Scale = {0.02, 0.14},
		Yaw = {-24.00, 24.00},
		Swirl = {19.25, 52.25},
		Stiffness = {56.70, 91.80},
		Ratio = {0.50, 0.65},
	},
	Orbit = {
		Reach = {0.61, 0.94},
		Lateral = {-0.50, 0.50},
		Depth = {0.22, 0.55},
		Yaw = {-56.00, 56.00},
		Swirl = {77.00, 129.25},
		Bank = {0.9, 1.4},
		Lead = {0.5, 1},
		Stiffness = {35.10, 62.10},
		Ratio = {0.51, 0.68},
		Wander = {0.50, 0.88},
	},
	Punch = {
		Reach = {0.39, 0.61},
		Depth = {-0.66, -0.39},
		Scale = {0.4, 0.68},
		Roll = {-20.40, 20.40},
		Swirl = {11.00, 33.00},
		Stiffness = {118.80, 189.00},
		Ratio = {0.41, 0.54},
		Wander = {0.22, 0.50},
		Cone = {-0.3, 0.35},
	},
	Tumble = {
		Reach = {0.52, 0.83},
		Rise = {0.12, 0.42},
		Pitch = {-228.00, 228.00},
		Yaw = {-48.00, 48.00},
		Roll = {-36.00, 36.00},
		Scale = {0.7, 0.9},
		Swirl = {60.50, 115.50},
		Bank = {0.85, 1.35},
		Stiffness = {37.80, 67.50},
		Ratio = {0.48, 0.64},
		Wander = {0.55, 0.99},
	},
	Drift = {
		Reach = {0.14, 0.30},
		Yaw = {-10.40, 10.40},
		Pitch = {-6.00, 6.00},
		Roll = {-7.20, 7.20},
		Scale = {0.93, 1},
		Swirl = {11.00, 35.75},
		Bank = {0.25, 0.6},
		Stiffness = {24.30, 45.90},
		Ratio = {0.55, 0.74},
		Wander = {0.66, 1.21},
		Fade = {35, 70},
	},
	Helix = {
		Reach = {0.50, 0.77},
		Rise = {-0.84, -0.42},
		Yaw = {-160.00, 160.00},
		Roll = {-22.80, 22.80},
		Swirl = {90.75, 145.75},
		Bank = {0.95, 1.45},
		Lead = {0.55, 1.05},
		Stiffness = {35.10, 62.10},
		Ratio = {0.50, 0.65},
		Wander = {0.55, 0.94},
	},
	Blinds = {
		Reach = {0.22, 0.44},
		Rise = {0.42, 0.78},
		Pitch = {-72.00, -39.00},
		Yaw = {-12.00, 12.00},
		Swirl = {16.50, 46.75},
		Stiffness = {62.10, 99.90},
		Ratio = {0.50, 0.65},
		Cone = {0.5, 1},
	},
}

local Order = {
	"Spin", "Slide", "Flip", "Swing", "Rise", "Fold",
	"Orbit", "Punch", "Tumble", "Drift", "Helix", "Blinds",
}

local Cache = {}

local function Build(Name: string)
	local Entry = {}
	for Key, Value in Base do
		Entry[Key] = Value
	end
	for Key, Value in Library[Name] or {} do
		Entry[Key] = Value
	end
	Entry.Name = Name
	return Entry
end

for _, Name in Order do
	Cache[Name] = Build(Name)
end

local InteractBase = {
	Scale = {Stiffness = 105, Ratio = 0.58},
	Offset = {Stiffness = 120, Ratio = 0.62},
	Rotation = {Stiffness = 90, Ratio = 0.55},
	Tint = {Stiffness = 150, Ratio = 0.85},
	Highlight = Color3.fromRGB(255, 255, 255),
	Shadow = Color3.fromRGB(0, 0, 0),
	Idle = {Scale = 1, Offset = Vector2.zero, Rotation = 0, Tint = 0},
	Hover = {Scale = 1.05, Offset = Vector2.new(0, -3), Rotation = 0, Tint = 0.26},
	Press = {Scale = 0.95, Offset = Vector2.new(0, 2), Rotation = 0, Tint = 0.48},
	Disabled = {Scale = 0.98, Offset = Vector2.zero, Rotation = 0, Tint = -0.45},
	Kick = {Scale = 0, Rotation = 0, Offset = Vector2.zero},
}

local InteractLibrary = {
	Button = {},

	Pop = {
		Scale = {Stiffness = 130, Ratio = 0.36},
		Hover = {Scale = 1.11, Offset = Vector2.new(0, -4), Tint = 0.3},
		Press = {Scale = 0.9, Offset = Vector2.new(0, 3), Tint = 0.52},
		Kick = {Scale = 0.9},
	},

	Tilt = {
		Rotation = {Stiffness = 70, Ratio = 0.42},
		Hover = {Scale = 1.04, Rotation = -4.5, Offset = Vector2.new(0, -2), Tint = 0.22},
		Press = {Scale = 0.97, Rotation = 2.5, Offset = Vector2.new(0, 2), Tint = 0.44},
		Kick = {Rotation = 26},
	},

	Lift = {
		Offset = {Stiffness = 95, Ratio = 0.5},
		Hover = {Scale = 1.03, Offset = Vector2.new(0, -8), Tint = 0.34},
		Press = {Scale = 1, Offset = Vector2.new(0, -2), Tint = 0.55},
		Kick = {Offset = Vector2.new(0, 22)},
	},

	Sink = {
		Scale = {Stiffness = 150, Ratio = 0.7},
		Hover = {Scale = 1.02, Offset = Vector2.new(0, -1), Tint = 0.18},
		Press = {Scale = 0.88, Offset = Vector2.new(0, 5), Tint = 0.6},
		Kick = {Scale = -0.5},
	},

	Nudge = {
		Offset = {Stiffness = 105, Ratio = 0.48},
		Hover = {Scale = 1.02, Offset = Vector2.new(7, 0), Rotation = -1.5, Tint = 0.24},
		Press = {Scale = 0.98, Offset = Vector2.new(11, 0), Rotation = 1, Tint = 0.44},
		Kick = {Offset = Vector2.new(-26, 0)},
	},

	Squish = {
		Scale = {Stiffness = 145, Ratio = 0.3},
		Hover = {Scale = 1.07, Rotation = -2, Tint = 0.26},
		Press = {Scale = 0.86, Rotation = 3, Offset = Vector2.new(0, 4), Tint = 0.5},
		Kick = {Scale = 1.4, Rotation = 14},
	},

	Glow = {
		Tint = {Stiffness = 90, Ratio = 0.9},
		Hover = {Scale = 1.015, Offset = Vector2.zero, Tint = 0.55},
		Press = {Scale = 0.99, Offset = Vector2.zero, Tint = 0.85},
		Kick = {Scale = 0.15},
	},

	Jelly = {
		Scale = {Stiffness = 165, Ratio = 0.16},
		Rotation = {Stiffness = 120, Ratio = 0.18},
		Offset = {Stiffness = 130, Ratio = 0.2},
		Hover = {Scale = 1.08, Offset = Vector2.new(0, -4), Tint = 0.28},
		Press = {Scale = 0.9, Offset = Vector2.new(0, 4), Rotation = 4, Tint = 0.5},
		Kick = {Scale = 1.6, Rotation = 34, Offset = Vector2.new(0, 26)},
	},

	Snap = {
		Scale = {Stiffness = 320, Ratio = 0.9},
		Offset = {Stiffness = 340, Ratio = 0.92},
		Rotation = {Stiffness = 300, Ratio = 0.9},
		Tint = {Stiffness = 400, Ratio = 1},
		Hover = {Scale = 1.04, Offset = Vector2.new(0, -2), Tint = 0.3},
		Press = {Scale = 0.96, Offset = Vector2.new(0, 2), Tint = 0.55},
	},

	Float = {
		Scale = {Stiffness = 34, Ratio = 0.6},
		Offset = {Stiffness = 30, Ratio = 0.58},
		Rotation = {Stiffness = 26, Ratio = 0.55},
		Tint = {Stiffness = 45, Ratio = 0.9},
		Hover = {Scale = 1.06, Offset = Vector2.new(0, -6), Rotation = -2, Tint = 0.3},
		Press = {Scale = 0.97, Offset = Vector2.new(0, 3), Tint = 0.5},
		Kick = {Offset = Vector2.new(0, 14)},
	},

	Recoil = {
		Offset = {Stiffness = 190, Ratio = 0.28},
		Rotation = {Stiffness = 140, Ratio = 0.26},
		Hover = {Scale = 1.03, Offset = Vector2.new(0, -2), Tint = 0.24},
		Press = {Scale = 0.93, Offset = Vector2.new(0, 9), Rotation = -5, Tint = 0.58},
		Kick = {Offset = Vector2.new(0, 46), Rotation = -30, Scale = -0.6},
	},

	Switch = {
		Scale = {Stiffness = 120, Ratio = 0.4},
		Offset = {Stiffness = 150, Ratio = 0.42},
		Hover = {Scale = 1.04, Offset = Vector2.new(0, -2), Tint = 0.22},
		Press = {Scale = 0.96, Offset = Vector2.new(0, 1), Tint = 0.4},
		Kick = {Scale = 0.7, Rotation = 10},
	},
}

local InteractOrder = {
	"Button", "Pop", "Tilt", "Lift", "Sink", "Nudge", "Squish",
	"Glow", "Jelly", "Snap", "Float", "Recoil", "Switch",
}

local InteractCache = {}

local function MergeState(Base, Override)
	local Result = {}
	for Key, Value in Base do
		Result[Key] = Value
	end
	for Key, Value in Override or {} do
		Result[Key] = Value
	end
	return Result
end

local function BuildInteract(Name: string)
	local Override = InteractLibrary[Name] or {}
	local Entry = {Name = Name}

	for _, Channel in {"Scale", "Offset", "Rotation", "Tint"} do
		Entry[Channel] = MergeState(InteractBase[Channel], Override[Channel])
	end
	for _, State in {"Idle", "Hover", "Press", "Disabled", "Kick"} do
		Entry[State] = MergeState(InteractBase[State], Override[State])
	end

	Entry.Highlight = Override.Highlight or InteractBase.Highlight
	Entry.Shadow = Override.Shadow or InteractBase.Shadow
	return Entry
end

for _, Name in InteractOrder do
	InteractCache[Name] = BuildInteract(Name)
end

Presets.Interact = InteractCache

function Presets.InteractNames(): {string}
	return table.clone(InteractOrder)
end

function Presets.GetInteract(Name: string?)
	return InteractCache[Name or ""] or InteractCache.Button
end

function Presets.Names(): {string}
	return table.clone(Order)
end

function Presets.Get(Name: string?)
	return Cache[Name or ""] or Cache.Spin
end

function Presets.Roll(Entry, Random: Random)
	local Result = {}
	for Key, Value in Entry do
		if type(Value) == "table" and #Value == 2 then
			Result[Key] = Value[1] + Random:NextNumber() * (Value[2] - Value[1])
		end
	end
	Result.Name = Entry.Name
	Result.Swirl *= (Random:NextNumber() < 0.5 and -1 or 1)
	return Result
end

function Presets.Fbm(Seed: number, Time: number, Rate: number): number
	local T = Time * Rate
	return math.noise(T, Seed, 0) * 0.62
		+ math.noise(T * 2.17, Seed, 11.7) * 0.27
		+ math.noise(T * 4.41, Seed, 23.9) * 0.11
end

return Presets
