# Sharper road markings

The original road textures (`newaspald.jpg` and friends in `1.dat`) are 256x500 pixels
and cover the whole road width, so the double yellow centre line is only about 6 pixels
tall and looks blurry up close. `repack_dat.py` re-renders the yellow and white
markings of every road texture at 3x resolution with crisp edges, and writes a new `1.dat`.

```
python patches/textures/repack_dat.py <original 1.dat> <new 1.dat>
```

Needs Python 3 with Pillow, NumPy and SciPy. The shipped `1.dat` is the output of this
script run on the original (from the first release, 5,733,632 bytes).
