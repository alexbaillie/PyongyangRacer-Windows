# Game patches

Both playable copies of the game are built from the untouched original in
`original/pyracer.swf` by swapping a few ActionScript classes for the files in
this folder, using [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler).

| Build | Patches applied | Shipped in |
|---|---|---|
| `pyracer.swf` (repository root) | `autodrive` | Windows package (Adobe Flash projector) |
| `ruffle/pyracer.swf` | `ruffle` + `autodrive` | macOS package (Ruffle) |

Nothing outside the listed classes is touched. Tracks, data files, physics and
the computer cars are the original game's.

## autodrive

A toggle the player switches on during a race by tapping the arrow keys
**Up, Down, Up, Up, Down, Down** (fresh presses, within about two seconds).
Entering it again switches it off. A message in the middle of the screen
confirms each change for five seconds.

While on:

- The car drives itself along a pre-computed **right-hand-lane line**: the lane
  immediately to the right of the double yellow centre line, all the way round
  the course. It never crosses the yellow line and stays in that lane unless a
  slower car is in the way; then, where the road has a second lane on the
  right, it moves one lane right, passes, and returns. Where there is no room
  it slows down and follows.
- It accelerates to top speed on straights and eases off for bends.
- The fuel gauge is held at full.
- It cannot leave the course: every tick the game's own terrain grid is checked
  at the car's new position and, if that position is out of bounds, the car is
  slid along the lane direction or held at its last good position instead. The
  computer cars pass through the player (and vice versa) rather than colliding,
  and "beaten" effects from thrown items are ignored.

Why a pre-computed line: the game's waypoints are too sparse for its sharp
corners (the straight line between some of them crosses out-of-bounds ground),
and two invisible collision boxes stand in the roadway on the game's own
waypoint path. The line in `tools/lane_line_as3.txt` is generated from the
level data by `tools/lane_line.py`, which reads the terrain grid, the road
mesh and its textures to find the yellow line and lane markings, offsets the
route into lane 1, routes corners through road cells, detours the collision
boxes, and verifies clearance everywhere. `tools/lane_extra_as3.txt` marks the
stretches with a usable second lane. The script also simulates the follower
with the game's car physics; `tools/wall_check.py` checks a line against the
collision boxes.

Files:

- `player/RGameClient.as`: key sequence detection in `KeyDownHandler`,
  `ToggleAutoDrive`, the follower in `AutoDriveLoop` (projection onto the
  line, look-ahead steering, speed rule, lane change logic), the embedded
  `AUTO_LINE` / `AUTO_EXTRA` data, collision skipping in `CollisionLoop`, the
  on-screen message, and resets on restart/quit.
- `player/RCar.as`: `AutoDriveGuard` (the out-of-bounds guard, called from
  `Tick` right after the car moves), `SetAction` ignoring knock-back actions,
  and `ReturnToTrack` disabled for the player while the mode is on.

To regenerate the line after changing the tool, run (needs Python 3 with
Pillow):

```
python patches/autodrive/tools/lane_line.py . patches/autodrive/tools
```

then paste the new arrays into `RGameClient.as` (or re-run
`tools/apply_autodrive.py` against freshly exported original sources).

## ruffle

Ruffle (the open-source Flash player used for the Mac build) does not yet
support the UVT data passed to `Graphics.drawTriangles()`, which the game uses
for all of its scenery. Without this patch the road and buildings render with
flat, screen-aligned textures. See Ruffle issues #14300 and #21709.

- `org/papervision3d/core/geom/TriangleMesh3D.as`: scenery triangles get classic
  per-corner UVs from their vertex data, skip `drawTriangles`, and switch their
  materials to Papervision's "precise" subdivision renderer with tiling so large
  ground triangles are perspective-corrected.
- `org/papervision3d/materials/BitmapMaterial.as`: the subdivision renderer
  assumed the camera's `focus` (50) for its perspective maths, but the game
  projects vertices with its own matrix offset by 60 units. The mismatch bent
  texture lines at sub-triangle boundaries (a visibly crooked yellow centre
  line). The renderer now uses 60.
- `org/papervision3d/core/clipping/FrustumClipping.as`: the near clipping plane
  moves from 0.001 to 30 world units; with the original value clipped vertices
  projected to coordinates in the millions and the ground vanished.
- `RockRacer.as`: stage scale mode `NO_SCALE` becomes `SHOW_ALL` so the game
  fills whatever window it is given.

The Windows package does not need any of this because Adobe's player supports
`drawTriangles` fully.

## Rebuilding the SWFs

You need Java 11 or newer and `ffdec.jar` from a JPEXS release (26.x works).
From the repository root:

```powershell
.\patches\build.ps1 -FfdecJar C:\path\to\ffdec.jar
```

The script stages each patch set into a temporary folder, runs FFDec's
`-importScript` against `patches/original/pyracer.swf`, and writes the two
output files into place. To do it by hand for one build, put the patch files
under a folder named `scripts` and run:

```
java -jar ffdec.jar -importScript patches/original/pyracer.swf out.swf <folder containing scripts/>
```

After rebuilding, re-create the release packages: the Windows zip is the
repository root minus `patches/`, `ruffle/` and git files; the Mac tarball is
`ruffle/pyracer.swf` plus the data files and Ruffle.app.
