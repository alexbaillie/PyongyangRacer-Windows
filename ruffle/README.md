# Ruffle build of the game

`pyracer.swf` in this folder is a patched copy of the game for use with
[Ruffle](https://ruffle.rs), the open-source Flash player. It is what the
macOS package on the Releases page ships. The Windows package in the repository
root uses the original, unmodified `pyracer.swf` with Adobe's Flash projector.

## Why a patch is needed

The game renders its scenery (terrain, road, buildings, sky, sea) with
`Graphics.drawTriangles()` and perspective UVT data. Ruffle 0.6.0 accepts that
call but ignores the UVT data, so every scenery triangle is filled with an
unrotated, screen-aligned copy of its texture. The cars use the classic
per-triangle `beginBitmapFill` path, which Ruffle supports, so they look fine.
Ruffle tracks this as an open limitation (issues #14300, #21709).

## What the patch changes

Two Papervision3D classes inside the SWF are replaced with the versions in
`patch/`:

- `core/geom/TriangleMesh3D.as`: scenery triangles get classic per-corner UVs
  copied from the vertex UVT data, skip the `drawTriangles` path, and enable
  Papervision's "precise" subdivision renderer on their materials (with tiling)
  so large ground triangles are perspective-corrected.
- `core/clipping/FrustumClipping.as`: the near clipping plane moves from 0.001
  to 30 world units in front of the camera. With the original value, clipped
  vertices projected to screen coordinates in the millions, which the
  subdivision renderer cannot resolve; the ground simply vanished.

Nothing else in the game is touched. Game logic, data files and inputs are
identical.

## Rebuilding

1. Get [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler)
   (needs Java).
2. Export the original scripts, or just use the two files in `patch/` laid out
   as `scripts/org/papervision3d/...`.
3. Run:

```
java -jar ffdec.jar -importScript ../pyracer.swf pyracer.swf <folder containing scripts/>
```

The patched SWF is about 1 KB larger than the original.
