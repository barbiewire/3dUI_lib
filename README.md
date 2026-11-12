# 3dUI_lib

**BIG THANKS to @SamsaSushi.** SamsaSushi wrote the script this module was based off of (found in the forum).

By barbedwire22, the rewriter and main coder for this module.

This module allows you to show your ui's in a 3d environment.
I don't recommend using this for real in-game environments because this is meant for floating cameras or main menus. More updates might come if this is something I'll enjoy doing.

ok so this makes ui that floats in the world instead of being flat on your screen.
it hangs in front of your camera, flies in with a lil spin, drifts while its just sitting there, and delays when you turn your camera.

everything you see move in here is physics, not tweens.

## How it actually works

there are zero tweens in this thing.
lit no durations, no keyframes, nothing that plays for "0.4 seconds" and then stops.

its all springs. a spring is just "here is a target, keep pulling toward it".
thats the whole thing, but that gets you:

- it never snaps into place, it kinda overshoots then settles
- you can interrupt it mid air and it just keeps flowing from wherever
- it never takes the same amount of time twice

and the presets are generative, meaning every time you open a panel it rolls fresh random numbers inside a range,
so the same preset never plays the same way twice.
different entry angle, different spin, different bounce, which is on purpose.

theres also a second spring on the FINAL position, so the panel is always trailing its own target.
thats what makes it drag behind your camera, and it works during the intro / exit too, not just when its idle.

## Setup

Put `ui3d` somewhere (with `Presets` inside it), then:

```lua
local Ui3d = require(workspace["3dUI_lib"].ui3d)

local Panel = Ui3d.new({
	Size = Vector2.new(6, 7.2),   -- studs
	PixelsPerStud = 100,          -- so canvas = 600 x 720 px
	AlwaysOnTop = true,
})

Panel:Open()
```

`Panel.Root` is a CanvasGroup filling the whole surface. thats where your ui goes. thats literally it.

## Using your own physical ui

build your ui by hand wherever you want (StarterGui, a template folder, whatever), then just drop it in:

```lua
local Content = SomeTemplate:Clone()
Content.Size = UDim2.fromScale(1, 1)
Content.Position = UDim2.fromScale(0, 0)
Content.Parent = Panel.Root

-- give every button some juice
for _, Thing in Content:GetDescendants() do
	if Thing:IsA("GuiButton") then
		Ui3d.Interact(Thing, "Pop")
	end
end

Panel:Open("Helix")
```

build your ui at the canvas size (Size * PixelsPerStud) or just use Scale sizing so it stretches on its own.
the canvas is FixedSize so it never reflows while the panel is animating.

## Presets: the 3d ones (how the panel flies in)

| Preset | |
| --- | --- |
| Spin | slides in while unwinding a spin |
| Slide | simple but curved, comes in from the side |
| Flip | card flip |
| Swing | hinges in from an edge like a door |
| Rise | comes up from below and levels out |
| Fold | unfolds from basically nothing |
| Orbit | big arc around you |
| Punch | slams in from the camera |
| Tumble | end over end |
| Drift | really soft and slow, barely moves |
| Helix | spirals in from below |
| Blinds | drops from above on a top hinge |

```lua
Panel:Open("Tumble")
Panel:Close()
Panel:Toggle("Orbit")
```

direction is `"Auto"` by default, which picks a random spot every time.
you can also pass `"Left"` `"Right"` `"Up"` `"Down"` `"Front"` `"Back"` or a raw Vector3 if you want it locked-ish
(it still jitters a lil so it isnt identical).

```lua
Panel:Open("Slide", "Right")
```

## Presets: the interactivity ones (hover / click)

| Preset | |
| --- | --- |
| Button | normal, small lift + squash, safe default |
| Pop | big bouncy scale |
| Tilt | rotates on hover, snaps on click |
| Lift | rises up and brightens |
| Sink | barely hovers, presses down hard |
| Nudge | slides sideways instead of up |
| Squish | scale + rotation, kinda cartoony |
| Glow | barely moves, mostly just lights up |
| Jelly | wobbles for ages, super loose |
| Snap | instant and crisp, no bounce |
| Float | slow and dreamy |
| Recoil | slams down then kicks back |
| Switch | tuned for toggle knobs |

```lua
local W = Ui3d.Interact(SomeButton, "Jelly")
W:SetEnabled(false)     -- greys out + stops responding
W:SetPreset("Snap")     -- swap it live
W:Impulse()             -- fire the click kick manually
W:Destroy()
```

or do a whole container at once:

```lua
Ui3d.InteractAll(Content, "Button")
```

hover and press are just spring targets, so yanking your mouse off mid press flows instead of cutting.
clicking also adds a velocity kick on top, thats why Recoil slams and Jelly wobbles instead of just easing.

## Panel api

| | |
| --- | --- |
| `Ui3d.new(options)` | make one |
| `Panel:Open(preset, dir)` | show it |
| `Panel:Close()` | hide it |
| `Panel:Toggle(preset, dir)` | flip it |
| `Panel:IsOpen()` | bool |
| `Panel:Nudge(impulse, spin)` | shove it, it recovers on its own |
| `Panel:Anchored(cframe)` | pin it to a world spot instead of your camera |
| `Panel:Configure(options)` | change settings live |
| `Panel:Destroy()` | gone |
| `Ui3d.All()` | every live panel |
| `Ui3d.CloseAll()` | |
| `Ui3d.DestroyAll()` | |
| `Ui3d.Unbind()` | kills the render loop |
| `Panel.Root` | your CanvasGroup |
| `Panel.Gui` | the SurfaceGui |
| `Panel.Part` | the actual part |

## Tuning (global multipliers, all default 1)

| | |
| --- | --- |
| `Ui3d.Tuning.Reach` | how far out it starts |
| `Ui3d.Tuning.Spin` | how much it rotates coming in |
| `Ui3d.Tuning.Damping` | higher = less overshoot |
| `Ui3d.Tuning.Stiffness` | higher = faster |
| `Ui3d.Tuning.Wander` | idle drift + turbulence |
| `Ui3d.Tuning.Swirl` | how curved the path in is |
| `Ui3d.Tuning.Bank` | how much it leans into its own movement |
| `Ui3d.Tuning.Follow` | lower = more camera drag |

set these before you open anything.
want it floatier? drop Damping to like 0.85 and bump Reach to 1.3. want it calmer? Damping 1.3.

## Stuff that will get you

1. **clicking needs `Interactive = true`.**
   by default the part has CanQuery = false and sits under the Camera, so the mouse goes straight through.
   thats on purpose, a hud panel shouldnt eat your clicks. for an actual menu: `Ui3d.new({Interactive = true})`.
   that flips CanQuery on, moves the part into workspace, and parents the SurfaceGui to PlayerGui with Adornee set to the part.
   now buttons work.

   input is also auto gated: the panel isnt clickable until its actually shown and nearly opaque,
   because the hitbox moves with the animation and you would otherwise be clicking where it USED to be mid flight.
   tweak with `InputFade` (default 0.92, thats the fade level it unlocks at).

   heads up: in edit mode theres no LocalPlayer so it quietly falls back to the normal setup. you need a playtest for real clicks.

2. **studio caches require().**
   if you edit this module and re-run from the command bar you will get the OLD version and lose your mind.
   either toggle play mode once, or clone the module to a fresh name and require the clone.

3. **position offsets get skipped inside a UIListLayout.**
   the layout owns Position so Interact cant move things in a list. scale rotation and tint still work fine.
   wrap it in a plain Frame if you want the lift ones to actually lift.

4. **hover / click need a real playtest.**
   edit mode has no mouse input into a SurfaceGui.
   you can fake it by setting `Widget.Hovering = true` and `Widget.Pressing = true` yourself.

## In Motion

Motion installs this from its Libraries page (Home) as **3D UI** and adds one easing style, **Physics**,
that you put on keyframes like any other easing. Between two keys the value is driven by this library's
spring (the same 240 Hz integrator, with the stiffness and damping from its presets and `Ui3d.Tuning`), so
it overshoots and settles instead of following a fixed curve, and it always lands exactly on the next key.
On Position keys the path curves the way a panel swirls in, and the object leans into its movement
(bank) on its Rotation. It plays inside the normal clip, in the editor and in the game.
